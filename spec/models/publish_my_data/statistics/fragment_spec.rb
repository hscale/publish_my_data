require 'spec_helper'

module PublishMyData
  module Statistics
    describe Fragment do
      context "empty" do
        subject(:fragment) { Fragment.new }

        its(:dimension_value_labels) { should be == [ ] }
      end

      context "with dimensions" do
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

        describe "#dimension_value_labels" do
          specify {
            expect(fragment.dimension_value_labels).to be == [ "Dimension 1 a", "Dimension 1 b" ]
          }
        end
      end
    end
  end
end
