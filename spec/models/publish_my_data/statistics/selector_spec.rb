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

      describe "persistence" do
        shared_examples_for "a Selector persistence implementation" do
          before(:each) do
            Selector.configure do |config|
              config.persistence_type     = persistence_type
              config.persistence_options  = persistence_options
            end
          end

          let(:selector) { Selector.new }

          before(:each) do
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset',
              dimensions: [
                {
                  dimension_uri: "http://example.com/dimension_1",
                  dimension_values: [
                    "http://example.com/dimension_value_1a",
                    "http://example.com/dimension_value_1b"
                  ]
                }
              ]
            )
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

              it "preserves all the values" do
                expect(selector_reloaded.to_h.fetch(:fragments)).to be == [
                  {
                    dataset_uri: 'http://example.com/dataset',
                    dimensions: [
                      {
                        dimension_uri: "http://example.com/dimension_1",
                        dimension_values: [
                          "http://example.com/dimension_value_1a",
                          "http://example.com/dimension_value_1b"
                        ]
                      }
                    ]
                  }
                ]
              end
            end
          end
        end

        describe "filesystem store" do
          let(:persistence_type) { :filesystem }
          let(:persistence_options) {
            { path: "tmp/selectors" }
          }

          before(:each) do
            FileUtils.rm_rf("tmp/selectors")
          end

          it_behaves_like "a Selector persistence implementation"
        end
      end

      describe "#id" do
        subject(:selector) { Selector.new }

        it "is a UUID" do
          expect(selector.id).to be_a(UUIDTools::UUID)
        end
      end

      describe "#header_rows" do
        subject(:selector) { Selector.new }

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
              dataset_uri: 'http://example.com/dataset', dimensions: [ ]
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
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [
                "http://example.com/dimension_value_1a",
                "http://example.com/dimension_value_1b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset', dimensions: [ dimension_1 ]
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
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [ "http://example.com/dimension_value_1a" ]
            }
          }

          let(:dimension_2) {
            {
              dimension_uri: "http://example.com/dimension_2",
              dimension_values: [
                "http://example.com/dimension_value_2a",
                "http://example.com/dimension_value_2b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset', dimensions: [ dimension_1, dimension_2 ]
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
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [
                "http://example.com/dimension_value_1a",
                "http://example.com/dimension_value_1b"
              ]
            }
          }

          let(:dimension_2) {
            {
              dimension_uri: "http://example.com/dimension_2",
              dimension_values: [
                "http://example.com/dimension_value_2a",
                "http://example.com/dimension_value_2b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset', dimensions: [ dimension_1, dimension_2 ]
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
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [
                "http://example.com/dimension_value_1a",
                "http://example.com/dimension_value_1b",
              ]
            }
          }

          before(:each) do
            # You wouldn't re-use a dimension across fragments for real,
            # but just to create an example it's fine
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset', dimensions: [ dimension_1 ]
            )
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset', dimensions: [ dimension_1 ]
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
              dimension_uri: "http://example.com/dimension_1",
              dimension_values: [ "http://example.com/dimension_value_1a" ]
            }
          }

          let(:dimension_2) {
            {
              dimension_uri: "http://example.com/dimension_2",
              dimension_values: [ "http://example.com/dimension_value_2a" ]
            }
          }

          let(:dimension_3) {
            {
              dimension_uri: "http://example.com/dimension_3",
              dimension_values: [
                "http://example.com/dimension_value_3a",
                "http://example.com/dimension_value_3b"
              ]
            }
          }

          before(:each) do
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset', dimensions: [ dimension_1 ]
            )
            selector.build_fragment(
              dataset_uri: 'http://example.com/dataset', dimensions: [ dimension_2, dimension_3 ]
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
    end
  end
end