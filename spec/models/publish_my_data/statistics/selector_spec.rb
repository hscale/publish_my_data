require 'spec_helper'

module PublishMyData
  module Statistics
    describe Selector do
      describe "#header_rows" do
        subject(:selector) { Selector.new }

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
            expect(labels_for(selector.header_rows)).to be == [ ]
          }
        end

        context "one fragment, no dimensions" do
          let(:dataset) { double("dataset") }

          before(:each) do
            selector.build_fragment([ ])
          end

          specify {
            expect(labels_for(selector.header_rows)).to be == [ ]
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
            expect(labels_for(selector.header_rows)).to be == [
              [ "Dimension 1 a", "Dimension 1 b" ]
            ]
          }

          specify {
            expect(widths_for(selector.header_rows)).to be == [
              [ 1, 1 ]
            ]
          }
        end

        context "one fragment, two dimensions of one and two values respectively" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [ dimension_value_1a ]
            }
          }

          let(:dimension_value_1a) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_1a",
              dimension_value_label:  "Dimension 1 a"
            }
          }


          let(:dimension_2) {
            {
              dimension_uri: "http://example.com/dimension_2",
              dimension_values: [ dimension_value_2a, dimension_value_2b ]
            }
          }

          let(:dimension_value_2a) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_2a",
              dimension_value_label:  "Dimension 2 a"
            }
          }

          let(:dimension_value_2b) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_2b",
              dimension_value_label:  "Dimension 2 b"
            }
          }

          before(:each) do
            selector.build_fragment([ dimension_1, dimension_2 ])
          end

          specify {
            expect(labels_for(selector.header_rows)).to be == [
              [ "Dimension 1 a" ],
              [ "Dimension 2 a", "Dimension 2 b" ]
            ]
          }

          specify {
            expect(widths_for(selector.header_rows)).to be == [
              [ 2 ], [ 1, 1 ]
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
            expect(labels_for(selector.header_rows)).to be == [
              [ "Dimension 1 a", "Dimension 1 b", "Dimension 1 a", "Dimension 1 b" ]
            ]
          }
        end

        context "two fragments, with one and two dimensions respectively" do
          let(:dataset) { double("dataset") }

          let(:dimension_1) {
            {
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [ dimension_value_1a ]
            }
          }

          let(:dimension_value_1a) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_1a",
              dimension_value_label:  "Dimension 1 a"
            }
          }

          let(:dimension_2) {
            {
              dimension_uri: "http://example.com/dimension_2",
              dimension_values: [ dimension_value_2a ]
            }
          }

          let(:dimension_value_2a) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_2a",
              dimension_value_label:  "Dimension 2 a"
            }
          }

          let(:dimension_3) {
            {
              dimension_uri: "http://example.com/dimension_3",
              dimension_values: [ dimension_value_3a, dimension_value_3b ]
            }
          }

          let(:dimension_value_3a) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_3a",
              dimension_value_label:  "Dimension 3 a"
            }
          }

          let(:dimension_value_3b) {
            {
              dimension_value_uri:    "http://example.com/dimension_value_3b",
              dimension_value_label:  "Dimension 3 b"
            }
          }

          before(:each) do
            selector.build_fragment([ dimension_1 ])
            selector.build_fragment([ dimension_2, dimension_3 ])
          end

          specify {
            expect(labels_for(selector.header_rows)).to be == [
              [ nil, "Dimension 2 a" ],
              [ "Dimension 1 a", "Dimension 3 a", "Dimension 3 b" ]
            ]
          }
        end
      end
    end
  end
end