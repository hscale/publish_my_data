require 'spec_helper'

module PublishMyData
  module Statistics
    describe Fragment do
      context "empty" do
        subject(:fragment) { Fragment.new }

        its(:dimension_value_labels) { should be == [ ] }
        its(:number_of_dimensions) { should be == 0 }
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

        describe "#dimension_value_labels" do
          specify {
            expect(fragment.dimension_value_labels).to be == [
              [ "Dimension 1 a" ],
              [ "Dimension 2 a", "Dimension 2 b" ]
            ]
          }
        end
      end
    end
  end
end
