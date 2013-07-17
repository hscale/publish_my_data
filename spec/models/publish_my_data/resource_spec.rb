require 'spec_helper'

module PublishMyData
  describe Resource do

    describe ".uri_from_host_and_doc_path" do

      context "with no format" do
        it "should return the uri formed from the host doc path" do
          Resource.uri_from_host_and_doc_path('example.com', 'hello/jello').should == 'http://example.com/id/hello/jello'
        end
      end

      context "with a format" do
        it "should return the uri formed from the host doc path, with the format stripped off" do
          Resource.uri_from_host_and_doc_path('example.com', 'hello/jello.rdf', 'rdf').should == 'http://example.com/id/hello/jello'
        end
      end

    end

    describe '.find_type' do
      context 'given an ontology URI' do
        let(:ontology) { FactoryGirl.create(:ontology) }

        it 'should return an Ontology' do
          Resource.find_type(ontology.uri).should be_a(PublishMyData::Ontology)
        end
      end

      context 'given a concept scheme URI' do
        let(:concept_scheme) { FactoryGirl.create(:concept_scheme) }

        it 'should return an Ontology' do
          Resource.find_type(concept_scheme.uri).should be_a(PublishMyData::ConceptScheme)
        end
      end
    end

    describe '#as_ontology' do
      let(:ontology) { FactoryGirl.create(:ontology) }
      let(:resource) { Resource.find(ontology.uri) }

      context 'where there is metadata about the ontology in a different graph' do
        before do
          query = "INSERT DATA { GRAPH <http://example.com/some/other/graph> {<#{ontology.uri}> <#{RDF::DCAT.keyword}> \"foo\"}};"
          Tripod::SparqlClient::Update.update(query)
        end

        it 'should restrict the returned results to the metadata graph only' do
          resource.as_ontology.tags.should be_empty
        end
      end
    end

    describe '#as_concept_scheme' do
      let(:concept_scheme) { FactoryGirl.create(:concept_scheme) }
      let(:resource) { Resource.find(concept_scheme.uri) }

      context 'where there is metadata about the ontology in a different graph' do
        before do
          query = "INSERT DATA { GRAPH <http://example.com/some/other/graph> {<#{concept_scheme.uri}> <#{RDF::DCAT.keyword}> \"foo\"}};"
          Tripod::SparqlClient::Update.update(query)
        end

        it 'should restrict the returned results to the metadata graph only' do
          resource.as_concept_scheme.tags.should be_empty
        end
      end
    end
  end
end