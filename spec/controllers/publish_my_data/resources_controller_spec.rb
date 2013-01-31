  require 'spec_helper'

module PublishMyData
  describe ResourcesController do

    describe "#show" do
      context "with a resource not in our database" do

        before do
          get :show, :uri => 'http://purl.org/linked-data/sdmx/2009/dimension%23refArea', use_route: :publish_my_data
        end

        context "html mime type" do

          context "with resource not in our database" do
            it "should redirect to the external uri" do
              response.should redirect_to('http://purl.org/linked-data/sdmx/2009/dimension%23refArea')
            end
          end

        end
      end

      context "with a resource in our database" do

        before do
          uri = 'http://uri'
          graph = 'http://graph'
          r = Resource.new(uri, graph)
          r.write_predicate('http://foo', 'blah')
          r.save!

          get :show, :uri => r.uri, use_route: :publish_my_data
        end

        it "should respond succesfully" do
          response.should be_success
        end

      end
    end
  end
end
