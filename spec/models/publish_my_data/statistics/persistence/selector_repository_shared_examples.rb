module PublishMyData
  module Statistics
    module Persistence
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
    end
  end
end
