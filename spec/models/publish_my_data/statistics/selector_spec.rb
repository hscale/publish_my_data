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
        subject(:selector) { Selector.new }

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
              let(:geography_type) { 'http://opendatacommunities.org/def/geography#LSOA' }
              let(:gss_codes) { ['E010000001', 'E010000002', 'E010000003'] }
              
              before(:each) do
                selector.gss_codes = gss_codes
                selector.geography_type = geography_type
                selector.save
              end

              let(:selector_reloaded) { Selector.find(selector.id) }

              it "preserves the id" do
                expect(selector_reloaded.id).to be == selector.id
              end

              it "preserves the fragments" do
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

              it "preserves the gss_codes" do
                expect(selector_reloaded.gss_codes).to be == gss_codes
              end

              it "preserves the de-normalised geography type" do
                expect(selector_reloaded.geography_type).to be == geography_type
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

          let(:selector) { Selector.new }

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
        subject(:selector) { Selector.new }

        it "is a UUID" do
          expect(selector.id).to be_a(UUIDTools::UUID)
        end
      end

      # See also the lint check above
      describe "ActiveModel" do
        describe "#to_key" do
          let(:test_uuid) { UUIDTools::UUID.parse("5409ef37-1589-4cb5-a7fd-e8a1c7722a09") }
          subject(:selector) { Selector.new(id: test_uuid) }

          before(:each) do
            selector.save # ActiveModel made me do it
          end

          its(:to_key) { should be == [ test_uuid ] }
        end

        describe "#to_param" do
          subject(:selector) { Selector.new }
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
          subject(:selector) { Selector.new }
          it "is always true (nothing we do yet can cause an error)" do
            expect(selector).to be_valid
          end
        end
      end

      describe '.new_from_csv' do
        subject(:selector) { Selector.new_from_csv(csv_upload) }

        # shoehorn data in
        before do
          Selector.instance_variable_set(:@gss_codes, nil) # don't cross the streams! Memo-ised variables called elsewhere will need resetting..
          RestClient::Request.execute(
            :method => :post,
            :url => "#{Tripod.data_endpoint}?graph=http://example.com/data",
            :payload =>  File.read(File.join(Rails.root, '../support/all_data.nt')),
            :headers => {content_type: 'text/plain'}
          )
        end

        context 'with a valid .csv upload containing a mix of GSS codes and supporting data' do
          let(:csv_upload) {
            temp_file = File.new(File.join(Rails.root, '../support/gss_etc.csv'))
            ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
          }

          it 'should return a new Selector' do
            selector.should be_a Selector
          end

          it 'should return a Selector with the GSS Codes property set to the contents of the uploaded CSV file which match a GSS code' do
            selector.gss_codes.should == [
              "E07000036",
              "E07000008",
              "E07000077",
              "E07000130",
              "E07000049"
            ]
          end

          it 'should return a Selector with the GSS Codes property set to the contents of the uploaded CSV file which match a GSS code' do
            selector.non_gss_codes.should == [
              "Beans",
              "Eggs",
              "Milk",
              "Fish",
              "Ham"
            ]
          end
        end

        context 'with a .csv upload containing GSS codes at both LA and LSOA level' do
          let(:csv_upload) {
            temp_file = File.new(File.join(Rails.root, '../support/gss_mixed.csv'))
            ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
          }

          it 'should raise a TooManyGSSCodeTypesError' do
            expect {
              selector
            }.to raise_error(Selector::TooManyGSSCodeTypesError)
          end
        end

        context 'with an invalid .csv upload' do
          let(:csv_upload) {
            temp_file = File.new(File.join(Rails.root, '../support/dog.gif'))
            ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
          }

          it 'should raise an InvalidCSVUploadError' do
            expect {
              selector
            }.to raise_error(Selector::InvalidCSVUploadError)
          end
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