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

    describe '.find' do
      context 'for a local resource' do
        let(:opts) { {local: true} }

        context 'of type Ontology' do
          let(:ontology) { FactoryGirl.create(:ontology) }

          it 'should return an Ontology given its URI' do
            Resource.find(ontology.uri, opts).should be_a(PublishMyData::Ontology)
          end
        end

        context 'of type ConceptScheme' do
          let(:concept_scheme) { FactoryGirl.create(:concept_scheme) }

          it 'should return a ConceptScheme' do
            Resource.find(concept_scheme.uri, opts).should be_a(PublishMyData::ConceptScheme)
          end
        end
      end

      context 'given an external concept scheme' do
        let(:concept_scheme) { FactoryGirl.create(:external_concept_scheme) }

        it 'should return a ThirdParty::ConceptScheme' do
          Resource.find(concept_scheme.uri).should be_a(PublishMyData::ThirdParty::ConceptScheme)
        end
      end

      context 'given an external ontology' do
        let(:ontology) { FactoryGirl.create(:external_ontology) }
        let(:domain) { 'http://pmde.test' }

        it 'should return a ThirdParty::Ontology' do
          Resource.find(ontology.uri).should be_a(PublishMyData::ThirdParty::Ontology)
        end

        context 'with an ontology class' do
          let(:ontology_class) { ontology.classes.first }

          it 'should return an OntologyClass given its URI' do
            Resource.find(ontology_class.uri).should be_a(PublishMyData::OntologyClass)
          end
        end

        context 'with an ontology property' do
          let(:property) { ontology.properties.first }

          it 'should return a Property given its URI' do
            Resource.find(property.uri).should be_a(PublishMyData::Property)
          end
        end
      end

      context 'given a resource of unknown type' do
        let(:resource) { FactoryGirl.create(:information_resource) }
        let(:domain) { 'http://pmde.test' }

        it 'should return a Resource' do
          Resource.find(resource.uri).should be_a(PublishMyData::Resource)
        end
      end
    end
  end
end