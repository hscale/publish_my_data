require 'spec_helper'

require 'fileutils'

module PublishMyData
  module Statistics
    describe Selector do
      class MockLabeller
        TEST_LABELS = {
          "http://example.com/dimension_value_1a" => "Dimension 1a",
          "http://example.com/dimension_value_1b" => "Dimension 1b",
          "http://example.com/dimension_value_2a" => "Dimension 2a",
          "http://example.com/dimension_value_2b" => "Dimension 2b",
          "http://example.com/dimension_value_3a" => "Dimension 3a",
          "http://example.com/dimension_value_3b" => "Dimension 3b"
        }.freeze

        def label_for(uri)
          TEST_LABELS.fetch(uri, "<label not found>")
        end
      end

      describe "interfaces" do
        subject(:selector) { Selector.new(geography_type: 'unused') }

        # Some of the Selector methods delegate to the repository, so
        # we have to re-lint for each repository type
        before(:each) do
          PublishMyData.configure do |config|
            config.stats_selector = {
              persistence_type:     persistence_type,
              persistence_options:  persistence_options
            }
          end
        end

        context "with a :filesystem store" do
          let(:persistence_type) { :filesystem }
          let(:persistence_options) {
            { path: "tmp/selectors_test" }
          }

          it_behaves_like "ActiveModel"
        end
      end

      describe "persistence" do
        shared_examples_for "a Selector persistence implementation" do
          let(:test_fragment_uuid) {
            UUIDTools::UUID.parse("460d107e-7f22-4bd4-a665-0f493041e75f")
          }

          before(:each) do
            unless respond_to?(:selector)
              raise 'Host example group must provide a Selector (eg `let(:selector) { ... }'
            end
          end

          before(:each) do
            PublishMyData.configure do |config|
              config.stats_selector = {
                persistence_type:     persistence_type,
                persistence_options:  persistence_options
              }
            end
          end

          before(:each) do
            selector.build_fragment(
              id:                   test_fragment_uuid,
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions: {
                "uri:dimension/1" => [
                  "http://example.com/dimension_value_1a",
                  "http://example.com/dimension_value_1b"
                ]
              }
            )
          end

          describe ".find" do
            it "only accepts UUIDs" do
              expect {
                Selector.find("foo")
              }.to raise_error(Selector::InvalidIdError, 'Invalid Selector id: "foo" (not a UUID)')
            end
          end

          describe "#save" do
            it "returns true" do
              expect(selector.save).to be_true
            end

            describe "reloading" do
              before(:each) do
                selector.save
              end

              let(:selector_reloaded) { Selector.find(selector.id) }

              it "preserves the id" do
                expect(selector_reloaded.id).to be == selector.id
              end

              it "preserves the geography type" do
                expect(
                  selector_reloaded.to_h.fetch(:geography_type)
                ).to be == selector.geography_type
              end

              it "preserves the row URIs" do
                expect(selector_reloaded.to_h.fetch(:row_uris)).to be == %w[
                  row:a row:b row:c
                ]
              end

              it "preserves all the fragment values" do
                expect(selector_reloaded.to_h.fetch(:fragments)).to be == [
                  {
                    id:                   test_fragment_uuid,
                    dataset_uri:          'uri:dataset/1',
                    measure_property_uri: 'uri:measure-property/1',
                    dimensions: {
                      "uri:dimension/1" => [
                        "http://example.com/dimension_value_1a",
                        "http://example.com/dimension_value_1b"
                      ]
                    }
                  }
                ]
              end
            end
          end

          describe "#destroy" do
            example do
              selector.save
              expect {
                selector.destroy
              }.to change { Selector.find(selector.id) }.to(nil)
            end

            it "is idempotent" do
              selector.save
              expect {
                selector.destroy
                selector.destroy
              }.to_not raise_error
            end
          end

          describe "#persisted?" do
            example do
              expect {
                selector.save
              }.to change { selector.persisted? }.from(false).to(true)
            end

            example do
              selector.save

              expect {
                selector.destroy
              }.to change { selector.persisted? }.from(true).to(false)
            end
          end
        end

        describe "filesystem store" do
          let(:persistence_type) { :filesystem }
          let(:persistence_options) {
            { path: "tmp/selectors_test" }
          }

          # The shared examples require these specific row URIs
          let(:selector) {
            Selector.new(geography_type: 'unused', row_uris: %w[ row:a row:b row:c ])
          }

          before(:each) do
            FileUtils.rm_rf("tmp/selectors_test")
          end

          it_behaves_like "a Selector persistence implementation"

          describe "the written file" do
            # This is a bit of a hack, we expose the repository just to be able
            # to read the raw data
            let(:file_data) { Selector.repository.data_for(selector.id) }

            before(:each) do
              selector.save
            end

            it "contains a version (in case we change anything significant in future)" do
              expect(file_data.fetch(:version)).to be == 1
            end
          end
        end
      end

      describe "#id" do
        subject(:selector) { Selector.new(geography_type: 'unused') }

        it "is a UUID" do
          expect(selector.id).to be_a(UUIDTools::UUID)
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

      describe "#header_rows" do
        subject(:selector) { Selector.new(geography_type: 'unused') }

        let(:labeller) { MockLabeller.new }

        def labels_for(header_rows)
          header_rows.map { |row|
            row.map { |column| column.label }
          }
        end

        def widths_for(header_rows)
          header_rows.map { |row|
            row.map { |column| column.number_of_encompassed_dimension_values }
          }
        end

        context "empty" do
          specify {
            # Not actually sure what this should do yet
            expect(labels_for(selector.header_rows(labeller))).to be == [ ]
          }
        end

        context "one fragment, no dimensions" do
          let(:dataset) { double("dataset") }

          before(:each) do
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions: { }
            )
          end

          specify {
            expect(labels_for(selector.header_rows(labeller))).to be == [ ]
          }
        end

        context "one fragment, one dimension with two values" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              "uri:dimension/1" => [
                "http://example.com/dimension_value_1a",
                "http://example.com/dimension_value_1b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions:           dimension_1
            )
          end

          specify {
            expect(labels_for(selector.header_rows(labeller))).to be == [
              [ "Dimension 1a", "Dimension 1b" ]
            ]
          }

          specify {
            expect(widths_for(selector.header_rows(labeller))).to be == [
              [ 1, 1 ]
            ]
          }
        end

        context "one fragment, two dimensions of one and two values respectively" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              "uri:dimension/1" => [ "http://example.com/dimension_value_1a" ]
            }
          }

          let(:dimension_2) {
            {
              "uri:dimension/2" => [
                "http://example.com/dimension_value_2a",
                "http://example.com/dimension_value_2b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions:           dimension_1.merge(dimension_2)
            )
          end

          specify {
            expect(labels_for(selector.header_rows(labeller))).to be == [
              [ "Dimension 1a" ],
              [ "Dimension 2a", "Dimension 2b" ]
            ]
          }

          specify {
            expect(widths_for(selector.header_rows(labeller))).to be == [
              [ 2 ], [ 1, 1 ]
            ]
          }
        end

        context "one fragment, two dimensions both of two values" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              "uri:dimension/1" => [
                "http://example.com/dimension_value_1a",
                "http://example.com/dimension_value_1b"
              ]
            }
          }

          let(:dimension_2) {
            {
              "uri:dimension/2" => [
                "http://example.com/dimension_value_2a",
                "http://example.com/dimension_value_2b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions:           dimension_1.merge(dimension_2)
            )
          end

          specify {
            expect(labels_for(selector.header_rows(labeller))).to be == [
              [ "Dimension 1a", "Dimension 1b" ],
              [ "Dimension 2a", "Dimension 2b", "Dimension 2a", "Dimension 2b" ]
            ]
          }

          specify {
            expect(widths_for(selector.header_rows(labeller))).to be == [
              [ 2, 2 ], [ 1, 1, 1, 1 ]
            ]
          }
        end

        context "two fragments, two dimensions with two values each" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              "uri:dimension/1" => [
                "http://example.com/dimension_value_1a",
                "http://example.com/dimension_value_1b",
              ]
            }
          }

          before(:each) do
            # You wouldn't re-use a dimension across fragments for real,
            # but just to create an example it's fine
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions:           dimension_1
            )
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions:           dimension_1
            )
          end

          specify {
            expect(labels_for(selector.header_rows(labeller))).to be == [
              [ "Dimension 1a", "Dimension 1b", "Dimension 1a", "Dimension 1b" ]
            ]
          }
        end

        context "two fragments, with one and two dimensions respectively" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              "uri:dimension/1" => [ "http://example.com/dimension_value_1a" ]
            }
          }

          let(:dimension_2) {
            {
              "uri:dimension/2" => [ "http://example.com/dimension_value_2a" ]
            }
          }

          let(:dimension_3) {
            {
              "http://example.com/dimension_3" => [
                "http://example.com/dimension_value_3a",
                "http://example.com/dimension_value_3b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions:           dimension_1
            )
            selector.build_fragment(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              dimensions:           dimension_2.merge(dimension_3)
            )
          end

          specify {
            expect(labels_for(selector.header_rows(labeller))).to be == [
              [ nil, "Dimension 2a" ],
              [ "Dimension 1a", "Dimension 3a", "Dimension 3b" ]
            ]
          }
        end
      end

      describe "#table_rows" do
        subject(:selector) {
          Selector.new(
            geography_type: "uri:statistical-geography",
            row_uris:       [ "uri:row_1" ]
          )
        }

        let(:labeller) { MockLabeller.new }

        let(:dimension_1) {
          {
            "uri:dimension/1" => [ "http://example.com/dimension_value_1a" ]
          }
        }

        let(:dimension_2) {
          {
            "uri:dimension/2" => [
              "http://example.com/dimension_value_2a",
              "http://example.com/dimension_value_2b"
            ]
          }
        }

        describe "Row construction" do
          let(:observation_source) {
            double(ObservationSource)
          }

          before(:each) do
            Selector::Row.stub(:new)
          end

          specify do
            selector.table_rows(observation_source, labeller)
            expect(Selector::Row).to have_received(:new).with(
              hash_including(
                observation_source:   observation_source,
                row_uri:              'uri:row_1'
              )
            )
          end
        end

        describe Selector::Row do
          # We're also testing the construction process here, for now
          let(:row) { selector.table_rows(observation_source, labeller).first }

          describe "#values" do
            let(:observation_source) {
              # Currently almost the same as the data in the Fragment spec
              MockObservationSource.new(
                measure_property_uris: %w[ uri:measure-property/1 uri:measure-property/2 ],
                observation_data: {
                  "uri:dataset/1" => {
                    "uri:row_1" => {
                      "uri:dimension/1" => {
                        "http://example.com/dimension_value_1a" => 1
                      },
                      "uri:dimension/2" => {
                        "http://example.com/dimension_value_2a" => 2,
                        "http://example.com/dimension_value_2b" => 3
                      }
                    }
                  }
                }
              )
            }

            context "one fragment" do
              before(:each) do
                # We demonstrate how multiple dimensions work in the Fragment spec
                selector.build_fragment(
                  dataset_uri:          'uri:dataset/1',
                  measure_property_uri: 'uri:measure-property/1',
                  dimensions:           dimension_1
                )
              end

              it "returns the correct values" do
                expect(row.values).to be == [1]
              end
            end

            context "two fragments" do
              before(:each) do
                # We demonstrate how multiple dimensions work in the Fragment spec
                # This hackily re-uses datasets across fragments to avoid adding
                # more data to the observation source
                selector.build_fragment(
                  dataset_uri:          'uri:dataset/1',
                  measure_property_uri: 'uri:measure-property/1',
                  dimensions:           dimension_1
                )
                selector.build_fragment(
                  dataset_uri:          'uri:dataset/1',
                  measure_property_uri: 'uri:measure-property/2',
                  dimensions:           dimension_2
                )
              end

              it "returns the correct values" do
                expect(row.values).to be == [1, 2, 3]
              end
            end
          end
        end
      end

      describe "#to_observation_query_options" do
        subject(:selector) {
          Selector.new(
            geography_type: 'uri:geography-type/1',
            row_uris:       ['uri:row/1', 'uri:row/2']
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

        it "returns all the data needed for an ObservationSource" do
          expect(selector.to_observation_query_options).to be == {
            row_dimension: 'http://opendatacommunities.org/def/ontology/geography/refArea',
            row_uris: ['uri:row/1', 'uri:row/2'],
            datasets: [
              {
                dataset_uri: 'uri:dataset/1' ,
                measure_property_uri: 'uri:measure-property/1',
                dimensions: {
                  'uri:dimension/1' => ['uri:dimension/1/val/1', 'uri:dimension/1/val/2'],
                  'uri:dimension/2' => ['uri:dimension/2/val/1', 'uri:dimension/2/val/2']
                }
              },
              {
                dataset_uri: 'uri:dataset/2' ,
                measure_property_uri: 'uri:measure-property/2',
                dimensions: {
                  'uri:dimension/3' => ['uri:dimension/3/val/1']
                }
              }
            ]
          }
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