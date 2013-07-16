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

      context 'given an ontology URI' do
        let(:concept_scheme) { FactoryGirl.create(:concept_scheme) }

        it 'should return an Ontology' do
          Resource.find_type(concept_scheme.uri).should be_a(PublishMyData::ConceptScheme)
        end
      end
    end
  end
end