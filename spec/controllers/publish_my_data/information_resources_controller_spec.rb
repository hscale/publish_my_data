require 'spec_helper'

module PublishMyData
  describe InformationResourcesController do

    describe "showing an information resource" do
      let!(:resource) { FactoryGirl.create(:information_resource) }

      shared_examples_for "resource show" do

        context "for an existing resource" do
          it  "should respond successfully" do
            get :show, id: "information/resource", use_route: :publish_my_data, :format => format
            response.should be_success
          end
        end

        context "with a non-existent dataset slug" do
          it "should respond with not found" do
            get :show, id: "non-existent/resource", use_route: :publish_my_data, :format => format
            response.should be_not_found
          end
        end
      end

      shared_examples_for "html format" do
        it "should render the resource show template" do
          get :show, id: "information/resource", use_route: :publish_my_data, :format => format
          response.should render_template("publish_my_data/resources/show")
        end
      end

      shared_examples_for "a non html format" do

        context "for an existing resource" do
          it "should return the resource in that format" do
            get :show, id: "information/resource", use_route: :publish_my_data, :format => format
            response.body.should == resource.send("to_#{format}")
          end
        end

        context "for a non-existent resource" do
          it "should return a blank body" do
            get :show, id: "non-existent/resource", use_route: :publish_my_data, :format => format
            response.body.should == "Not Found"
          end
        end
      end

      context "for html format" do
        let(:format){ 'html' }
        it_should_behave_like "html format"
        it_should_behave_like "resource show"
      end

      # try another format.
      context "for rdf format" do
        let(:format){ 'rdf' }
        it_should_behave_like "a non html format"
        it_should_behave_like "resource show"
      end

    end

    describe "showing a dataset" do

      let(:dataset) { FactoryGirl.create(:my_dataset) }

      shared_examples_for "dataset show" do

        context "for an existing dataset" do
          it  "should respond successfully" do
            get :show, id: dataset.slug, use_route: :publish_my_data, :format => format
            response.should be_success
          end
        end

        context "with a non-existent dataset slug" do
          it "should respond with not found" do
            get :show, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
            response.should be_not_found
          end
        end
      end

      shared_examples_for "html format" do
        it "should render the dataset show template" do
          get :show, id: dataset.slug, use_route: :publish_my_data, :format => format
          response.should render_template("publish_my_data/datasets/show")
        end
      end

      shared_examples_for "a non html format" do

        context "for an existing dataset" do
          it "should return the dataset dtls in that format" do
            get :show, id: dataset.slug, use_route: :publish_my_data, :format => format
            response.body.should == dataset.send("to_#{format}")
          end
        end

        context "for a non-existent dataset slug" do
          it "should return a blank body" do
            get :show, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
            response.body.should == "Not Found"
          end
        end
      end

      context "for html format" do
        let(:format){ 'html' }
        it_should_behave_like "html format"
        it_should_behave_like "dataset show"
      end

      context "for rdf format" do
        let(:format){ 'rdf' }
        it_should_behave_like "a non html format"
        it_should_behave_like "dataset show"
      end

      context "for json format" do
        let(:format){ 'json' }

        # note: we don't use the shared example group here because the JSON format sometimes brings stuff back in different orders!

        context "for an existing dataset" do
          it "should return the dataset dtls in that format" do
            get :show, id: dataset.slug, use_route: :publish_my_data, :format => format
            JSON.parse(response.body).should == JSON.parse(dataset.send("to_#{format}"))
          end
        end

        context "for a non-existent dataset slug" do
          it "should return a blank body" do
            get :show, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
            response.body.should == "Not Found"
          end
        end

        it_should_behave_like "dataset show"
      end

      context "for ttl format" do
        let(:format){ 'ttl' }
        it_should_behave_like "a non html format"
        it_should_behave_like "dataset show"
      end

      context "for ntriples format" do
        let(:format){ 'nt' }
        it_should_behave_like "a non html format"
        it_should_behave_like "dataset show"
      end

    end

  end
end