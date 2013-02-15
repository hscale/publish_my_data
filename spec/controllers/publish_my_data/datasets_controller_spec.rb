require 'spec_helper'

module PublishMyData
  describe DatasetsController do

    describe "#show" do

      context "with an existing dataset slug" do

        let(:dataset) { FactoryGirl.create(:my_dataset) }

        it "should respond successfully" do
          get :show, id: dataset.slug, use_route: :publish_my_data
          response.should be_success
        end
      end

      context "with a non-existent dataset slug" do
        it "should respond successfully" do
          get :show, id: "slug-that-doesnt-exist", use_route: :publish_my_data
          response.should be_not_found
        end
      end

    end

  end
end