require 'spec_helper'

module PublishMyData
  module Statistics
    describe Selector do
      describe "#header_rows" do
        subject(:selector) { Selector.new }

        context "empty" do
          specify {
            # One row with an empty list of values in it
            expect(selector.header_rows).to be == [ [] ]
          }
        end

        context "one fragment, no dimensions" do
          let(:dataset) { double("dataset") }

          before(:each) do
            selector.build_fragment([ ])
          end

          specify {
            # One row with an empty list of values in it
            expect(selector.header_rows).to be == [ [] ]
          }
        end

        context "one fragment, one dimension with two values" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [ dimension_value_1a, dimension_value_1b ]
            }
          }

          let(:dimension_value_1a) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_1a",
              dimension_value_label:  "Dimension 1 a"
            }
          }

          let(:dimension_value_1b) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_1b",
              dimension_value_label:  "Dimension 1 b"
            }
          }

          before(:each) do
            selector.build_fragment([ dimension_1 ])
          end

          specify {
            expect(selector.header_rows).to be == [
              [ "Dimension 1 a", "Dimension 1 b" ]
            ]
          }
        end

        context "two fragments, two dimensions with two values each" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [ dimension_value_1a, dimension_value_1b ]
            }
          }

          let(:dimension_value_1a) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_1a",
              dimension_value_label:  "Dimension 1 a"
            }
          }

          let(:dimension_value_1b) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_1b",
              dimension_value_label:  "Dimension 1 b"
            }
          }

          before(:each) do
            # You wouldn't re-use a dimension across fragments for real,
            # but just to create an example it's fine
            selector.build_fragment([ dimension_1 ])
            selector.build_fragment([ dimension_1 ])
          end

          specify {
            expect(selector.header_rows).to be == [
              [ "Dimension 1 a", "Dimension 1 b", "Dimension 1 a", "Dimension 1 b" ]
            ]
          }
        end
      end
    end
  end
end