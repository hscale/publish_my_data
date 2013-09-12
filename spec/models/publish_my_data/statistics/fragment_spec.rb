require 'spec_helper'

module PublishMyData
  module Statistics
    describe Fragment do
      context "empty" do
        subject(:fragment) { Fragment.new }

        its(:dimension_value_labels) { should be == [ ] }
        its(:number_of_dimensions) { should be == 0 }

        describe "#number_of_encompassed_dimension_values_at_level" do
          specify {
            expect(fragment.number_of_encompassed_dimension_values_at_level(0)).to be == 0
          }
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
                  {
                    dimension_value_uri:    "http://example.com/dimension_value_1a",
                    dimension_value_label:  "Dimension 1 a"
                  },
                  {
                    dimension_value_uri:    "http://example.com/dimension_value_1b",
                    dimension_value_label:  "Dimension 1 b"
                  }
                ]
              }
            ]
          )
        }

        its(:number_of_dimensions) { should be == 1 }

        describe "#dimension_value_labels" do
          specify {
            expect(fragment.dimension_value_labels).to be == [
              [ "Dimension 1 a", "Dimension 1 b" ]
            ]
          }
        end

        describe "#number_of_encompassed_dimension_values_at_level" do
          example "level 0" do
            expect(fragment.number_of_encompassed_dimension_values_at_level(0)).to be == 1
          end

          example "level -1" do
            expect(fragment.number_of_encompassed_dimension_values_at_level(-1)).to be == 1
          end
        end
      end

      context "with two dimensions" do
        subject(:fragment) {
          Fragment.new(
            [
              {
                dimension_uri: "http://example.com/dimension_1",
                dimension_values: [
                  {
                    dimension_value_uri:    "http://example.com/dimension_value_1a",
                    dimension_value_label:  "Dimension 1 a"
                  }
                ]
              },
              {
                dimension_uri: "http://example.com/dimension_2",
                dimension_values: [
                  {
                    dimension_value_uri:    "http://example.com/dimension_value_2a",
                    dimension_value_label:  "Dimension 2 a"
                  },
                  {
                    dimension_value_uri:    "http://example.com/dimension_value_2b",
                    dimension_value_label:  "Dimension 2 b"
                  }
                ]
              }
            ]
          )
        }

        its(:number_of_dimensions) { should be == 2 }

        its(:volume_of_selected_cube) { should be == 2 }

        describe "#volume_at_level" do
          example "level 0" do
            expect(fragment.volume_at_level(0)).to be == 1
          end

          example "level 1" do
            expect(fragment.volume_at_level(1)).to be == 2
          end
        end

        # Terrible examples - we need another layer!
        describe "#volume_at_level_above" do
          example "above level 0" do
            expect(fragment.volume_at_level_above(0)).to be == 1
          end

          example "above level 1" do
            expect(fragment.volume_at_level_above(1)).to be == 1
          end

          example "above level -1" do
            expect(fragment.volume_at_level_above(-1)).to be == 1
          end

          example "above level -2" do
            expect(fragment.volume_at_level_above(-2)).to be == 1
          end

          example do
            pending "need to test higher levels - there are edge case bugs lurking somewhere"
          end
        end

        describe "#dimension_value_labels" do
          specify {
            expect(fragment.dimension_value_labels).to be == [
              [ "Dimension 1 a" ],
              [ "Dimension 2 a", "Dimension 2 b" ]
            ]
          }
        end

        describe "#number_of_encompassed_dimension_values_at_level" do
          example "level 0" do
            expect(fragment.number_of_encompassed_dimension_values_at_level(0)).to be == 2
          end

          example "level 1" do
            expect(fragment.number_of_encompassed_dimension_values_at_level(1)).to be == 1
          end

          example "level -1" do
            expect(fragment.number_of_encompassed_dimension_values_at_level(-1)).to be == 1
          end

          example "level -2" do
            expect(fragment.number_of_encompassed_dimension_values_at_level(-2)).to be == 2
          end
        end
      end
    end
  end
end
