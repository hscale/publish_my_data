require 'spec_helper'

shared_examples 'as json' do
  it "should return its json" do
    JSON.parse(response.body).should == JSON.parse(resource.to_json)
  end

  it "should respond successfully" do
    response.should be_success
  end
end

shared_examples 'as rdf' do
  it "should return its rdf" do
    response.body.should == resource.to_rdf
  end

  it "should respond successfully" do
    response.should be_success
  end
end

shared_examples 'as ttl' do
  it "should return its ttl" do
    response.body.should == resource.to_ttl
  end

  it "should respond successfully" do
    response.should be_success
  end
end

shared_examples "as n-triples" do
  it "should return the its n-triples" do
    response.body.should == resource.to_nt
  end

  it "should respond successfully" do
    response.should be_success
  end
end

module PublishMyData
  describe InformationResourcesController do

    describe '#data' do
      context "given a dataset" do
        let(:resource) { FactoryGirl.create(:my_dataset) }

        context 'as html' do
          before { get :data, id: resource.slug, use_route: :publish_my_data }

          it "should render the dataset show template" do
            response.should render_template("publish_my_data/datasets/show")
          end

          it "should respond successfully" do
            response.should be_success
          end
        end

        context "as rdf" do
          before { get :data, id: resource.slug, use_route: :publish_my_data, :format => 'rdf' }
          include_examples 'as rdf'
        end

        context "as json" do
          before { get :data, id: resource.slug, use_route: :publish_my_data, :format => 'json' }
          include_examples 'as json'
        end

        context "as ttl" do
          before { get :data, id: resource.slug, use_route: :publish_my_data, :format => 'ttl' }
          include_examples 'as ttl'
        end

        context "as n-triples" do
          before { get :data, id: resource.slug, use_route: :publish_my_data, :format => 'nt' }
          include_examples 'as n-triples'
        end
      end

      context "given an arbitrary information resource which is not a dataset" do
        let!(:resource) { FactoryGirl.create(:information_resource) }

        context 'as html' do
          before { get :data, id: "information/resource", use_route: :publish_my_data }

          it "should render the resource show template" do
            response.should render_template("publish_my_data/resources/show")
          end

          it "should respond successfully" do
            response.should be_success
          end
        end

        context "as rdf" do
          before { get :data, id: "information/resource", use_route: :publish_my_data, :format => 'rdf' }
          include_examples 'as rdf'
        end

        context "as json" do
          before { get :data, id: "information/resource", use_route: :publish_my_data, :format => 'json' }
          include_examples 'as json'
        end

        context "as ttl" do
          before { get :data, id: "information/resource", use_route: :publish_my_data, :format => 'ttl' }
          include_examples 'as ttl'
        end

        context "as n-triples" do
          before { get :data, id: "information/resource", use_route: :publish_my_data, :format => 'nt' }
          include_examples 'as n-triples'
        end
      end

      describe 'given a non-existent identifier' do
        it "should respond with not found" do
          get :data, id: "non-existent/resource", use_route: :publish_my_data
          response.should be_not_found
        end
      end
    end

    describe "#def" do
      context "when resource is an ontology" do
        let!(:resource) { FactoryGirl.create(:ontology) }

        it "should respond successfully" do
          get :def, :id => "my-topic", use_route: :publish_my_data
          response.should be_success
        end

        it "should render the ontologies#show template" do
          get :def, :id => "my-topic", use_route: :publish_my_data
          response.should render_template("publish_my_data/ontologies/show")
        end

        context "as rdf" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'rdf' }
          include_examples 'as rdf'
        end

        context "as json" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'json' }
          include_examples 'as json'
        end

        context "as ttl" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'ttl' }
          include_examples 'as ttl'
        end

        context "as n-triples" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'nt' }
          include_examples 'as n-triples'
        end
      end

      context "when resource is a concept scheme" do
        let!(:resource) { FactoryGirl.create(:concept_scheme) }

        it "should respond successfully" do
          get :def, :id => "my-topic", use_route: :publish_my_data
          response.should be_success
        end

        it "should render the concept_schemes#show template" do
          get :def, :id => "my-topic", use_route: :publish_my_data
          response.should render_template("publish_my_data/concept_schemes/show")
        end

        context "as rdf" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'rdf' }
          include_examples 'as rdf'
        end

        context "as json" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'json' }
          include_examples 'as json'
        end

        context "as ttl" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'ttl' }
          include_examples 'as ttl'
        end

        context "as n-triples" do
          before { get :def, :id => "my-topic", use_route: :publish_my_data, :format => 'nt' }
          include_examples 'as n-triples'
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