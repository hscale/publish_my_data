require 'spec_helper'

module PublishMyData
  describe InformationResourcesController do
    describe '#data' do
      describe "given a dataset" do

        let(:dataset) { FactoryGirl.create(:my_dataset) }

        shared_examples_for "dataset show" do

          context "for an existing dataset" do
            it  "should respond successfully" do
              get :data, id: dataset.slug, use_route: :publish_my_data, :format => format
              response.should be_success
            end
          end

          context "with a non-existent dataset slug" do
            it "should respond with not found" do
              get :data, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
              response.should be_not_found
            end
          end
        end

        shared_examples_for "dataset html format" do
          it "should render the dataset show template" do
            get :data, id: dataset.slug, use_route: :publish_my_data, :format => format
            response.should render_template("publish_my_data/datasets/show")
          end
        end

        shared_examples_for "dataset non html format" do

          context "for an existing dataset" do
            it "should return the dataset dtls in that format" do
              get :data, id: dataset.slug, use_route: :publish_my_data, :format => format
              response.body.should == dataset.send("to_#{format}")
            end
          end

          context "for a non-existent dataset slug" do
            it "should return a blank body" do
              get :data, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
              response.body.should == "Not Found"
            end
          end
        end

        context "for html format" do
          let(:format){ 'html' }
          it_should_behave_like "dataset html format"
          it_should_behave_like "dataset show"
        end

        context "for rdf format" do
          let(:format){ 'rdf' }
          it_should_behave_like "dataset non html format"
          it_should_behave_like "dataset show"
        end

        context "for json format" do
          let(:format){ 'json' }

          # note: we don't use the shared example group here because the JSON format sometimes brings stuff back in different orders!

          context "for an existing dataset" do
            it "should return the dataset dtls in that format" do
              get :data, id: dataset.slug, use_route: :publish_my_data, :format => format
              JSON.parse(response.body).should == JSON.parse(dataset.send("to_#{format}"))
            end
          end

          context "for a non-existent dataset slug" do
            it "should return a blank body" do
              get :data, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
              response.body.should == "Not Found"
            end
          end

          it_should_behave_like "dataset show"
        end

        context "for ttl format" do
          let(:format){ 'ttl' }
          it_should_behave_like "dataset non html format"
          it_should_behave_like "dataset show"
        end

        context "for ntriples format" do
          let(:format){ 'nt' }
          it_should_behave_like "dataset non html format"
          it_should_behave_like "dataset show"
        end
      end

      describe "given an arbitrary information resource which is not a dataset" do
        let!(:resource) { FactoryGirl.create(:information_resource) }

        shared_examples_for "resource show" do

          context "for an existing resource" do
            it  "should respond successfully" do
              get :data, id: "information/resource", use_route: :publish_my_data, :format => format
              response.should be_success
            end
          end

          context "with a non-existent dataset slug" do
            it "should respond with not found" do
              get :data, id: "non-existent/resource", use_route: :publish_my_data, :format => format
              response.should be_not_found
            end
          end
        end

        shared_examples_for "resource html format" do
          it "should render the resource show template" do
            get :data, id: "information/resource", use_route: :publish_my_data, :format => format
            response.should render_template("publish_my_data/resources/show")
          end
        end

        shared_examples_for "resource non html format" do

          context "for an existing resource" do
            it "should return the resource in that format" do
              get :data, id: "information/resource", use_route: :publish_my_data, :format => format
              response.body.should == resource.send("to_#{format}")
            end
          end

          context "for a non-existent resource" do
            it "should return a blank body" do
              get :data, id: "non-existent/resource", use_route: :publish_my_data, :format => format
              response.body.should == "Not Found"
            end
          end
        end

        context "for html format" do
          let(:format){ 'html' }
          it_should_behave_like "resource html format"
          it_should_behave_like "resource show"
        end

        # try another format.
        context "for rdf format" do
          let(:format){ 'rdf' }
          it_should_behave_like "resource non html format"
          it_should_behave_like "resource show"
        end
      end
    end

    describe "#def" do
      context "for an abitrary resource" do
        let!(:resource) { FactoryGirl.create(:mean_result) }

        it "should respond successfully" do
          get :def, :id => "statistics/meanResult", use_route: :publish_my_data
          response.should be_success
        end

        it "should render the show template" do
          get :def, :id => "statistics/meanResult", use_route: :publish_my_data
          response.should render_template("publish_my_data/resources/show")
        end

        context "given an alternative format" do
          it "should respond with the right content" do
            get :def, :id => "statistics/meanResult", :format => 'nt', use_route: :publish_my_data
            response.body.should == resource.to_nt
          end

          it "should respond with the appropriate mime type" do
            get :def, :id => "statistics/meanResult", :format => 'nt', use_route: :publish_my_data
            response.content_type.should == Mime::NT
          end
        end
      end

      context "when resource is an ontology" do
        let!(:ontology) { FactoryGirl.create(:ontology) }

        it "should respond successfully" do
          get :def, :id => "ontology/my-topic", use_route: :publish_my_data
          response.should be_success
        end

        it "should render the ontologies#show template" do
          get :def, :id => "ontology/my-topic", use_route: :publish_my_data
          response.should render_template("publish_my_data/ontologies/show")
        end
      end

      context "when resource is a concept scheme" do
        let!(:concept_scheme) { FactoryGirl.create(:concept_scheme) }

        it "should respond successfully" do
          get :def, :id => "concept-scheme/my-topic", use_route: :publish_my_data
          response.should be_success
        end

        it "should render the concept_schemes#show template" do
          get :def, :id => "concept-scheme/my-topic", use_route: :publish_my_data
          response.should render_template("publish_my_data/concept_schemes/show")
        end
      end

      context "when resource doesn't exist" do
        it "should 404" do
          get :def, :id => "statistics/nonExistent", use_route: :publish_my_data
          response.should be_not_found
        end
      end
    end
  end
end