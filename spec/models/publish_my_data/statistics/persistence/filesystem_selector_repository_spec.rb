require 'spec_helper'
require_relative 'selector_repository_shared_examples'

module PublishMyData
  module Statistics
    module Persistence
      describe FilesystemSelectorRepository do
        let(:persistence_type) { :filesystem }
        let(:persistence_options) {
          { path: "tmp/selectors_test" }
        }

        # The shared examples require these specific row URIs
        let(:selector) {
          Selector.new(geography_type: 'unused', row_uris: %w[ row:a row:b row:c ])
        }

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
  end
end