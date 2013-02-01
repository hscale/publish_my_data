require 'spec_helper'

module PublishMyData
  describe ResourcesController do

    describe "#id" do

      context "with html mime type" do

        before do
          get :id, :path => "this/is/my/path", use_route: :publish_my_data
        end

        it "should redirect to the corresponding doc view with a 303" do
          response.status.should eq(303)
          response.should redirect_to "/doc/this/is/my/path"
        end
      end

      context "with an alternative mime type passed in the header" do
        before do
          @request.env['HTTP_ACCEPT'] = "application/rdf+xml"
          get :id, :path => "this/is/my/path", use_route: :publish_my_data
        end

        it "should keep that mime type when doing the 303" do
          response.status.should eq(303)
          response.should redirect_to "/doc/this/is/my/path"
          response.headers["Content-Type"].should include("application/rdf+xml")
        end
      end
    end

    describe "#doc" do

      before do
        @resource = FactoryGirl.create(:unicorn_resource)
      end

      it "should respond successfully" do
        get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        response.should be_success
      end

      context "with an alternative mime type passed in the header" do

        before do
          @request.env['HTTP_ACCEPT'] = "application/rdf+xml"
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        it "should resond with the right mime type" do
          response.headers["Content-Type"].should eq("application/rdf+xml")
        end

        it "should respond with the right content" do
          response.body.should == @resource.to_rdf
        end

      end

      context "with an alternative fomat passed on the url" do

        before do
          @request.env['HTTP_ACCEPT'] = "text/turtle"
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        it "should resond with the right mime type" do
          response.headers["Content-Type"].should eq("text/turtle")
        end

        it "should respond with the right content" do
          response.body.should == @resource.to_ttl
        end

      end


    end

    describe "#show" do

      context "with a resource not in our database" do

        uri = "http://purl.org/linked-data/sdmx/2009/dimension%23refArea"

        context "html mime type" do

          before do
            get :show, :uri => uri, use_route: :publish_my_data
          end

          context "with resource not in our database" do
            it "should redirect to the external uri" do
              response.should redirect_to('http://purl.org/linked-data/sdmx/2009/dimension%23refArea')
            end
          end

        end

        context "non html mime type" do

          before do
            get :show, :uri => uri, :format => 'rdf', use_route: :publish_my_data
          end

          it "should 404" do
            response.should be_not_found
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
