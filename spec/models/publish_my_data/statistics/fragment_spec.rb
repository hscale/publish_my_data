require 'spec_helper'

module PublishMyData
  module Statistics
    describe Fragment do
      context "empty" do
        subject(:fragment) { Fragment.new }

        its(:number_of_dimensions) { should be == 0 }
        its(:volume_of_selected_cube) { should be == 1 }

        its(:dimension_value_labels) { should be == [ ] }

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
      end

      context "with one dimension" do
        subject(:fragment) {
          Fragment.new(
            # An array...
            [
              # ... of hashes...
              {
                # ... of dimensions ...
                dimension_uri: "http://example.com/dimension_1",
                dimension_values: [
                  { dimension_value_uri: "1a", dimension_value_label: "Dim 1a" },
                  { dimension_value_uri: "1b", dimension_value_label: "Dim 1b" }
                ]
              }
            ]
          )
        }

        its(:number_of_dimensions) { should be == 1 }

        its(:volume_of_selected_cube) { should be == 2 }

        describe "#dimension_value_labels" do
          specify {
            expect(fragment.dimension_value_labels).to be == [
              [ "Dim 1a", "Dim 1b" ]
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
      end

      context "three dimensions" do
        subject(:fragment) {
          Fragment.new(
            [
              {
                dimension_uri: "1",
                dimension_values: [
                  { dimension_value_uri: "1a", dimension_value_label:  "Dim 1a" },
                  { dimension_value_uri: "1b", dimension_value_label:  "Dim 1b" }
                ]
              },
              {
                dimension_uri: "2",
                dimension_values: [
                  { dimension_value_uri: "2a", dimension_value_label:  "Dim 2a" },
                  { dimension_value_uri: "2b", dimension_value_label:  "Dim 2b" },
                  { dimension_value_uri: "2c", dimension_value_label:  "Dim 2c" }
                ]
              },
              {
                dimension_uri: "3",
                dimension_values: [
                  { dimension_value_uri: "3a", dimension_value_label:  "Dim 3a" },
                  { dimension_value_uri: "3b", dimension_value_label:  "Dim 3b" },
                  { dimension_value_uri: "3c", dimension_value_label:  "Dim 3c" },
                  { dimension_value_uri: "3d", dimension_value_label:  "Dim 3d" }
                ]
              },
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
              [ "Dim 1a", "Dim 1b" ],
              [
                "Dim 2a", "Dim 2b", "Dim 2c",
                "Dim 2a", "Dim 2b", "Dim 2c"
              ],
              [
                "Dim 3a", "Dim 3b", "Dim 3c", "Dim 3d",
                "Dim 3a", "Dim 3b", "Dim 3c", "Dim 3d",
                "Dim 3a", "Dim 3b", "Dim 3c", "Dim 3d",
                "Dim 3a", "Dim 3b", "Dim 3c", "Dim 3d",
                "Dim 3a", "Dim 3b", "Dim 3c", "Dim 3d",
                "Dim 3a", "Dim 3b", "Dim 3c", "Dim 3d"
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
      end
    end
  end
end
