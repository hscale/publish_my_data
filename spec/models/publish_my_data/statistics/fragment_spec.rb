require 'spec_helper'

module PublishMyData
  module Statistics
    describe Fragment do
      describe '#id' do
        subject(:fragment) {
          Fragment.new(
            dataset_uri:          'uri:dataset/1',
            measure_property_uri: 'uri:measure-property/1',
            dimensions:           { }
          )
        }

        it 'should assign an identifier during instantiation' do
          fragment.id.should_not be_blank
        end
      end

      context "empty" do
        subject(:fragment) {
          Fragment.new(
            dataset_uri:          'uri:dataset/1',
            measure_property_uri: 'uri:measure-property/1',
            dimensions:           { }
          )
        }

        its(:number_of_dimensions) { should be == 0 }
        its(:volume_of_selected_cube) { should be == 1 }

        describe "#number_of_encompassed_dimension_values_at_level" do
          describe "positive indexing" do
            example "level 0" do
              expect(fragment.number_of_encompassed_dimension_values_at_level(0)).to be == 0
            end
          end

          describe "negative indexing" do
            example "level -1" do
              expect(fragment.number_of_encompassed_dimension_values_at_level(-1)).to be == 0
            end
          end
        end
      end

      context "with one dimension" do
        subject(:fragment) {
          Fragment.new(
            dataset_uri:          'uri:dataset/1',
            measure_property_uri: 'uri:measure-property/1',
            dimensions: {
              "uri:dimension/1" => [ 'uri:1/a', 'uri:1/b' ]
            }
          )
        }

        # Currently this is the only example of this method
        # #inform_snapshot is in a different block
        describe "#inform_observation_source" do
          let(:observation_source) {
            double(ObservationSource,
              row_uris_detected:  nil,
              dataset_detected:   nil
            )
          }

          it "notifies the observation source of the dataset" do
            fragment.inform_observation_source(observation_source)

            expect(observation_source).to have_received(:dataset_detected).with(
              dataset_uri: 'uri:dataset/1' ,
              measure_property_uri: 'uri:measure-property/1',
              dimensions: {
                'uri:dimension/1' => ['uri:1/a', 'uri:1/b']
              }
            )
          end
        end

        its(:number_of_dimensions) { should be == 1 }
        its(:volume_of_selected_cube) { should be == 2 }

        describe "#number_of_encompassed_dimension_values_at_level" do
          describe "positive indexing" do
            example "level 0" do
              expect(fragment.number_of_encompassed_dimension_values_at_level(0)).to be == 1
            end
          end

          describe "negative indexing" do
            example "level -1" do
              expect(fragment.number_of_encompassed_dimension_values_at_level(-1)).to be == 1
            end
          end
        end
      end

      context "three dimensions" do
        subject(:fragment) {
          Fragment.new(
            dataset_uri:          'uri:dataset/1',
            measure_property_uri: 'uri:measure-property/1',
            dimensions: {
              'uri:dimension/1' => [ 'uri:1/a', 'uri:1/b' ],
              'uri:dimension/2' => [ 'uri:2/a', 'uri:2/b', 'uri:2/c' ],
              'uri:dimension/3' => [ 'uri:3/a', 'uri:3/b', 'uri:3/c', 'uri:3/d' ]
            }
          )
        }

        # Ditto - maybe we should break these methods out into a
        # content-independent example group
        describe "#inform_snapshot" do
          let(:snapshot) {
            double(Snapshot, dataset_detected: nil, dimension_detected: nil)
          }

          before(:each) do
            fragment.inform_snapshot(snapshot)
          end

          it "notifies the snapshot of the dataset" do
            # I'm guessing we need the measure property URI here
            # (we do need it somewhere though)
            expect(snapshot).to have_received(:dataset_detected).with(
              dataset_uri: 'uri:dataset/1' ,
              measure_property_uri: 'uri:measure-property/1'
            )
          end

          it "notifies the snapshot of each dimension (header row)" do
            expect(snapshot).to have_received(:dimension_detected).with(
              dimension_uri: 'uri:dimension/1',
              column_width: 12,
              column_uris: ['uri:1/a', 'uri:1/b']
            )
            expect(snapshot).to have_received(:dimension_detected).with(
              dimension_uri: 'uri:dimension/2',
              column_width: 4,
              column_uris: ['uri:2/a', 'uri:2/b', 'uri:2/c']
            )
            expect(snapshot).to have_received(:dimension_detected).with(
              dimension_uri: 'uri:dimension/3',
              column_width: 1,
              column_uris: ['uri:3/a', 'uri:3/b', 'uri:3/c', 'uri:3/d']
            )
          end

          it "notifies the snapshot of the dimension rows from the bottom up" do
            # When spies support ordering, let's prove that it works
            # https://github.com/rspec/rspec-mocks/issues/430
            # (I'm not messing up the rest of the code)
            expect(snapshot).to have_received(:dimension_detected).with(
              hash_including(dimension_uri: 'uri:dimension/3')
            )#.ordered
            expect(snapshot).to have_received(:dimension_detected).with(
              hash_including(dimension_uri: 'uri:dimension/2')
            )#.ordered
            expect(snapshot).to have_received(:dimension_detected).with(
              hash_including(dimension_uri: 'uri:dimension/1')
            )#.ordered
          end
        end

        describe "#inform_labeller" do
          let(:labeller) { double(Labeller, resource_detected: nil) }

          before(:each) do
            fragment.inform_labeller(labeller)
          end

          %w[
            uri:dataset/1
            uri:measure-property/1
            uri:dimension/1
            uri:1/a uri:1/b
            uri:2/a uri:2/b uri:2/c
            uri:3/a uri:3/b uri:3/c uri:3/d
          ].each do |resource_uri|
            specify {
              expect(labeller).to have_received(:resource_detected).with(resource_uri)
            }
          end
        end

        its(:number_of_dimensions) { should be == 3 }
        its(:volume_of_selected_cube) { should be == 24 }

        describe "#number_of_encompassed_dimension_values_at_level" do
          describe "positive indexing" do
            example "level 0" do
              expect(fragment.number_of_encompassed_dimension_values_at_level(0)).to be == 12
            end

            example "level 1" do
              expect(fragment.number_of_encompassed_dimension_values_at_level(1)).to be == 4
            end

            example "level 2" do
              expect(fragment.number_of_encompassed_dimension_values_at_level(2)).to be == 1
            end
          end

          describe "negative indexing" do
            example "level -3" do
              expect(
                fragment.number_of_encompassed_dimension_values_at_level(-3)
              ).to be == fragment.number_of_encompassed_dimension_values_at_level(0)
            end

            example "level -2" do
              expect(
                fragment.number_of_encompassed_dimension_values_at_level(-2)
              ).to be == fragment.number_of_encompassed_dimension_values_at_level(1)
            end

            example "level -1" do
              expect(
                fragment.number_of_encompassed_dimension_values_at_level(-1)
              ).to be == fragment.number_of_encompassed_dimension_values_at_level(2)
            end
          end
        end
      end
    end
  end
end
