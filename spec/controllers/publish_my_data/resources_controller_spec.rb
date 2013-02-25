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
          response.content_type.should == Mime::RDF
        end
      end

    end

    describe "#doc" do

      before do
        @resource = FactoryGirl.create(:yuri_unicorn_resource)
      end

      it "should respond successfully" do
        get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        response.should be_success
      end

      it "should render the doc template" do
        get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        response.should render_template("publish_my_data/resources/doc")
      end

      context "for html" do
        it "should eager load the labels" do
          Resource.should_receive(:find).and_return(@resource)
          @resource.should_receive(:eager_load_predicate_triples!)
          @resource.should_receive(:eager_load_object_triples!)
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end
      end

      context "with an alternative mime type passed in the header" do

        before do
          @request.env['HTTP_ACCEPT'] = "application/rdf+xml"
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        it "should resond with the right mime type" do
          response.content_type.should == Mime::RDF
        end

        it "should respond with the right content" do
          response.body.should == @resource.to_rdf
        end

        it "should not eager load the labels" do
          Resource.should_receive(:find).and_return(@resource)
          @resource.should_not_receive(:eager_load_predicate_triples!)
          @resource.should_not_receive(:eager_load_object_triples!)
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        context "and the resource doesn't exist" do
          it "should 404 with a blank response" do
            get :doc, :path => "unicorns/borat", use_route: :publish_my_data
            response.should be_not_found
            response.body.should be_blank
          end
        end

      end

      context "with an alternative format passed on the url" do

        it "should resond with the right mime type" do
          get :doc, :path => "unicorns/yuri", format: 'ttl', use_route: :publish_my_data
          response.content_type.should == Mime::TTL
        end

        it "should respond with the right content" do
          get :doc, :path => "unicorns/yuri", format: 'ttl', use_route: :publish_my_data
          response.body.should == @resource.to_ttl
        end

      end

      context "when resource doesn't exist" do

        before do
          get :doc, :path => "doesnt/exist", use_route: :publish_my_data
        end

        it "should 404" do
          response.should be_not_found
        end

      end

    end

    describe "#definition" do

      before do
        @resource = FactoryGirl.create(:mean_result)
      end

      context "for resource in our database" do

        it "should respond successfully" do
          get :definition, :path => "statistics/meanResult", use_route: :publish_my_data
          response.should be_success
        end

        it "should render the doc template" do
          get :definition, :path => "statistics/meanResult", use_route: :publish_my_data
          response.should render_template("publish_my_data/resources/doc")
        end

        context "with an alternative mime type" do
          it "should with the right mime type and content" do
            get :definition, :path => "statistics/meanResult", :format => 'nt', use_route: :publish_my_data
            response.content_type.should == Mime::NT
            response.body.should == @resource.to_nt
          end
        end

      end

      context "when resource doesn't exist" do
        it "should 404" do
          get :definition, :path => "statistics/nonExistent", use_route: :publish_my_data
          response.should be_not_found
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

        it "should render the show template" do
          response.should render_template("publish_my_data/resources/show")
        end

      end
    end

    describe "#index" do
      context "with no parameters" do
        it "should respond successfully" do
          get :index, :use_route => :publish_my_data
        end

        it "should return paginated results for Resource.all" do
          subject.should_receive(:paginate_resources).with(Resource.all)
          get :index, :use_route => :publish_my_data
        end
      end
    end



  end
end
