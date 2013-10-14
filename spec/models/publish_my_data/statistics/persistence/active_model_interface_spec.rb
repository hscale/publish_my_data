require 'spec_helper'

module PublishMyData
  module Statistics
    module ActiveModelInterfaceSpec
      describe "ActiveModel interface" do
        subject(:selector) { Selector.new(geography_type: 'unused') }

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
    end
  end
end