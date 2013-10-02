require 'spec_helper'

module PublishMyData
  module Statistics
    describe Fragment do
      context "empty" do
        subject(:fragment) {
          Fragment.new(dataset_uri: 'http://example.com/dataset', dimensions: [ ])
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

        describe "#volume_at_level" do
          describe "positive indexing" do
            example "level 0" do
              expect(fragment.volume_at_level(0)).to be == 1
            end
          end

          describe "negative indexing" do
            example "level -1" do
              expect(fragment.volume_at_level(-1)).to be == 1
            end
          end
        end

        describe "#volume_at_level_above" do
          describe "positive indexing" do
            example "above level 0" do
              expect(fragment.volume_at_level_above(0)).to be == 1
            end
          end

          describe "negative indexing" do
            example "above level -1" do
              expect(fragment.volume_at_level_above(-1)).to be == 1
            end
          end
        end

        describe "#values_for_row" do
          let(:observation_source) { :unused }

          specify {
            expect(
              fragment.values_for_row(
                "uri:unused_type", "uri:unused_resource", observation_source
              )
            ).to be == []
          }
        end
      end

      context "with one dimension" do
        subject(:fragment) {
          Fragment.new(
            dataset_uri: 'http://example.com/dataset',
            # An array...
            dimensions: [
              # ... of hashes...
              {
                # ... of dimensions ...
                dimension_uri: "http://example.com/dimension_1",
                dimension_values: [ "1a", "1b" ]
              }
            ]
          )
        }

        its(:number_of_dimensions) { should be == 1 }
        its(:volume_of_selected_cube) { should be == 2 }

        describe "#dimension_value_labels" do
          specify {
            expect(fragment.dimension_value_labels).to be == [
              [ "1a", "1b" ]
            ]
          }
        end

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

        describe "#volume_at_level" do
          example "level 0" do
            expect(fragment.volume_at_level(0)).to be == 2
          end
        end

        describe "#volume_at_level_above" do
          describe "positive indexing" do
            example "above level 0" do
              expect(fragment.volume_at_level_above(0)).to be == 1
            end
          end

          describe "negative indexing" do
            example "above level -1" do
              expect(fragment.volume_at_level_above(-1)).to be == 1
            end
          end
        end

        describe "#values_for_row" do
          let(:observation_source) {
            MockObservationSource.new(
              "http://example.com/dataset" => {
                "uri:row_type_1" => {
                  "uri:row_1" => {
                    "http://example.com/dimension_1" => {
                      "1a" => 1, "1b" => 2
                    }
                  }
                }
              }
            )
          }

          specify {
            expect(
              fragment.values_for_row("uri:row_type_1", "uri:row_1", observation_source)
            ).to be == [1, 2]
          }
        end
      end

      context "three dimensions" do
        subject(:fragment) {
          Fragment.new(
            dataset_uri: 'http://example.com/dataset',
            dimensions: [
              {
                dimension_uri: "1",
                dimension_values: [ "1a", "1b" ]
              },
              {
                dimension_uri: "2",
                dimension_values: [ "2a", "2b", "2c" ]
              },
              {
                dimension_uri: "3",
                dimension_values: [ "3a", "3b", "3c", "3d" ]
              }
            ]
          )
        }

        its(:number_of_dimensions) { should be == 3 }

        its(:volume_of_selected_cube) { should be == 24 }

        describe "#volume_at_level" do
          it "needs to mean the same with level 0 as the selector" do
            pending
          end

          describe "positive indexing" do
            example "level 0" do
              expect(fragment.volume_at_level(0)).to be == 2
            end

            example "level 1" do
              expect(fragment.volume_at_level(1)).to be == 6
            end

            example "level 2" do
              expect(fragment.volume_at_level(2)).to be == 24
            end
          end

          describe "negative indexing (-1 == 3)" do
            example "level -4" do
              expect(fragment.volume_at_level(-4)).to be == 1
            end

            example "level -3" do
              expect(fragment.volume_at_level(-3)).to be == fragment.volume_at_level(0)
            end

            example "level -2" do
              expect(fragment.volume_at_level(-2)).to be == fragment.volume_at_level(1)
            end

            example "level -1" do
              expect(fragment.volume_at_level(-1)).to be == fragment.volume_at_level(2)
            end
          end
        end

        describe "#volume_at_level_above" do
          describe "positive indexing" do
            example "above level 0" do
              expect(fragment.volume_at_level_above(0)).to be == 1
            end

            example "above level 1" do
              expect(fragment.volume_at_level_above(1)).to be == fragment.volume_at_level(0)
            end

            example "above level 2" do
              expect(fragment.volume_at_level_above(2)).to be == fragment.volume_at_level(1)
            end

            example "above level 3" do
              expect(fragment.volume_at_level_above(3)).to be == fragment.volume_at_level(2)
            end
          end

          describe "negative indexing" do
            example "above level -3" do
              expect(fragment.volume_at_level_above(-3)).to be == 1
            end

            example "above level -2" do
              expect(fragment.volume_at_level_above(-2)).to be == fragment.volume_at_level(0)
            end

            example "above level -1" do
              expect(fragment.volume_at_level_above(-1)).to be == fragment.volume_at_level(1)
            end
          end
        end

        describe "#dimension_value_labels" do
          specify {
            expect(fragment.dimension_value_labels).to be == [
              [ "1a", "1b" ],
              [
                "2a", "2b", "2c",
                "2a", "2b", "2c"
              ],
              [
                "3a", "3b", "3c", "3d",
                "3a", "3b", "3c", "3d",
                "3a", "3b", "3c", "3d",
                "3a", "3b", "3c", "3d",
                "3a", "3b", "3c", "3d",
                "3a", "3b", "3c", "3d"
              ]
            ]
          }
        end

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

        describe "#values_for_row" do
          # I probably should have made a simpler 3-dimensional example context for this :-S
          let(:observation_source) {
            MockObservationSource.new(
              "http://example.com/dataset" => {
                "uri:row_type_1" => {
                  "uri:row_1" => {
                    "1" => {
                      "1a" => {
                        "2" => {
                          "2a" => { "3" => { "3a" => 1, "3b" =>  2, "3c" =>  3, "3d" =>  4 } },
                          "2b" => { "3" => { "3a" => 5, "3b" =>  6, "3c" =>  7, "3d" =>  8 } },
                          "2c" => { "3" => { "3a" => 9, "3b" => 10, "3c" => 11, "3d" => 12 } }
                        }
                      },
                      "1b" => {
                        "2" => {
                          "2a" => { "3" => { "3a" => 13, "3b" => 14, "3c" => 15, "3d" => 16 } },
                          "2b" => { "3" => { "3a" => 17, "3b" => 18, "3c" => 19, "3d" => 20 } },
                          "2c" => { "3" => { "3a" => 21, "3b" => 22, "3c" => 23, "3d" => 24 } }
                        }
                      }
                    }
                  }
                }
              }
            )
          }

          specify {
            expect(
              fragment.values_for_row("uri:row_type_1", "uri:row_1", observation_source)
            ).to be == [
              1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24
            ]
          }
        end
      end
    end
  end
end
