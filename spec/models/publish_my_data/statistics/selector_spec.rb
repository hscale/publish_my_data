require 'spec_helper'

require 'fileutils'

module PublishMyData
  module Statistics
    describe Selector do
      describe "#id" do
        subject(:selector) { Selector.new(geography_type: 'unused') }

        it "is a UUID" do
          expect(selector.id).to be_a(UUIDTools::UUID)
        end
      end

      describe "#empty?" do
        subject(:selector) { Selector.new(geography_type: 'unused') }

        context "new" do
          its(:empty?) { should be_true}
        end

        context "with a fragment" do
          before(:each) do
            # Note that while the fragment has no dimensions, we still
            # consider the selector non-empty here, as we enforce through
            # the UI that fragments must have values for the dimensions
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions: { }
            )
          end

          its(:empty?) { should be_false }
        end
      end

      # See also the lint check above
      describe "ActiveModel" do
        describe "#to_key" do
          let(:test_uuid) { UUIDTools::UUID.parse("5409ef37-1589-4cb5-a7fd-e8a1c7722a09") }

          subject(:selector) {
            Selector.new(geography_type: 'unused', id: test_uuid)
          }

          before(:each) do
            selector.save # ActiveModel made me do it
          end

          its(:to_key) { should be == [ test_uuid ] }
        end

        describe "#to_param" do
          subject(:selector) { Selector.new(geography_type: 'unused') }
          let(:param) { selector.to_param }

          before(:each) do
            selector.save # ActiveModel made me do it
          end

          it "uses the id" do
            expect(param).to be == selector.id.to_s
          end

          it "looks like a UUID" do
            expect(param).to match(/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/)
          end
        end

        describe "#valid?" do
          subject(:selector) { Selector.new(geography_type: 'unused') }

          it "is always true (nothing we do yet can cause an error)" do
            expect(selector).to be_valid
          end
        end
      end

      describe "#take_snapshot" do
        let(:snapshot) {
          double(Snapshot,
            dataset_detected:   nil,
            dimension_detected: nil,
            dataset_completed:  nil,
            row_uris_detected:  nil
          )
        }

        let(:observation_source) {
          double(ObservationSource,
            row_uris_detected: nil,
            dataset_detected:   nil
          )
        }

        let(:labeller) {
          double(Labeller, resource_detected: nil)
        }

        subject(:selector) {
          Selector.new(
            geography_type: 'uri:geography-type/1',
            row_uris:       ['uri:row/1', 'uri:row/2', 'uri:row/3']
          )
        }

        before(:each) do
          selector.build_fragment(
            dataset_uri:          'uri:dataset/1',
            measure_property_uri: 'uri:measure-property/1',
            dimensions: {
              'uri:dimension/1' => ['uri:dimension/1/val/1', 'uri:dimension/1/val/2'],
              'uri:dimension/2' => ['uri:dimension/2/val/1', 'uri:dimension/2/val/2']
            }
          )
          selector.build_fragment(
            dataset_uri:          'uri:dataset/2',
            measure_property_uri: 'uri:measure-property/2',
            dimensions: {
              'uri:dimension/3' => ['uri:dimension/3/val/1']
            }
          )
        end

        context "no row limit (usual case)" do
          let!(:snapshot_result) {
            selector.take_snapshot(snapshot, observation_source, labeller)
          }

          it "returns nil, as this is a command method that mutates the snapshot" do
            expect(snapshot_result).to be_nil
          end

          describe "priming the labeller" do
            %w[ uri:row/1 uri:row/2 uri:row/3 ].each do |resource_uri|
              specify {
                expect(labeller).to have_received(:resource_detected).with(resource_uri)
              }
            end
          end

          describe "priming the observation source" do
            it "notifies the observation source of the datasets" do
              # Full interaction is specified in Fragment
              expect(observation_source).to have_received(:dataset_detected).with(
                hash_including(dataset_uri: 'uri:dataset/1')
              )

              expect(observation_source).to have_received(:dataset_detected).with(
                hash_including(dataset_uri: 'uri:dataset/2')
              )
            end

            it "notifies the observation source of the rows" do
              expect(observation_source).to have_received(:row_uris_detected).with(
                'http://opendatacommunities.org/def/ontology/geography/refArea',
                ['uri:row/1', 'uri:row/2', 'uri:row/3']
              )
            end
          end

          describe "priming the snapshot" do
            it "informs the snapshot of the datasets" do
              # Full interaction is specified in Fragment
              # Not sure we need to pass the dataset URI but for now it will
              # do as proof that we told the Fragment to inform the snapshot
              expect(snapshot).to have_received(:dataset_detected).with(
                hash_including(dataset_uri: 'uri:dataset/1')
              )

              expect(snapshot).to have_received(:dataset_detected).with(
                hash_including(dataset_uri: 'uri:dataset/2')
              )
            end

            it "informs the snapshot of the rows" do
              expect(snapshot).to have_received(:row_uris_detected).with(
                ['uri:row/1', 'uri:row/2', 'uri:row/3']
              )
            end
          end
        end

        context "row limit (for preview, only one interesting deviation from above)" do
          let!(:snapshot_result) {
            selector.take_snapshot(snapshot, observation_source, labeller, row_limit: 2)
          }

          describe "priming the labeller" do
            it "fetches labels for rows in the snapshot" do
              expect(labeller).to have_received(:resource_detected).with('uri:row/1')
              expect(labeller).to have_received(:resource_detected).with('uri:row/2')
            end

            # Full interaction is specified in Fragment
            it "tells the fragments to inform the labeller of their resources" do
              expect(labeller).to have_received(:resource_detected).with('uri:dataset/1')
              expect(labeller).to have_received(:resource_detected).with('uri:dataset/2')
            end

            # This only saves us a trivial amount of database query time but
            # seems more correct somehow...
            it "doesn't fetch labels for rows not in the snapshot" do
              expect(labeller).to_not have_received(:resource_detected).with('uri:row/3')
            end
          end

          describe "priming the observation source" do
            it "notifies the observation source of the rows" do
              expect(observation_source).to have_received(:row_uris_detected).with(
                'http://opendatacommunities.org/def/ontology/geography/refArea',
                ['uri:row/1', 'uri:row/2']
              )
            end
          end

          describe "priming the snapshot" do
            it "informs the snapshot of the rows" do
              expect(snapshot).to have_received(:row_uris_detected).with(
                ['uri:row/1', 'uri:row/2']
              )
            end
          end
        end
      end

      describe '#remove_fragment' do
        subject(:selector) { Selector.new(geography_type: 'unused') }

        let!(:fragment) {
          selector.build_fragment(
            dataset_uri: 'uri:unused', measure_property_uri: 'uri:unused', dimensions: {}
          )
        }

        it 'should remove the fragment with the given identifier' do
          selector.remove_fragment(fragment.id)
          selector.fragments.should_not include(fragment)
        end
      end
    end
  end
end