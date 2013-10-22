require 'spec_helper'

module PublishMyData
  describe Dataset do
    let(:dataset) { FactoryGirl.build(:my_dataset) }

    it_behaves_like PublishMyData::AllFeatures do
      let(:resource) { dataset }
    end

    describe '#types' do
      let(:type_one) { 'http://example.com/types/one' }
      let(:type_two) { 'http://example.com/types/two' }
      before do
        r = Resource.new('http://example.com/id/foo', dataset.data_graph_uri)
        r.rdf_type = type_one
        r.save!
        r = Resource.new('http://example.com/id/bar', dataset.data_graph_uri)
        r.rdf_type = type_two
        r.save!
      end

      it 'should return resources for the types used in the dataset' do
        dataset.types.map(&:uri).should == [type_one, type_two]
      end
    end

    describe '#type_count' do
      let(:type_uri) { 'http://example.com/types/one' }

      before do
        r = Resource.new('http://example.com/id/foo', dataset.data_graph_uri)
        r.rdf_type = type_uri
        r.save!
        r = Resource.new('http://example.com/id/bar', dataset.data_graph_uri)
        r.rdf_type = type_uri
        r.save!
      end

      it 'should return the resource count for the given type in the dataset' do
        dataset.type_count(type_uri).should == 2
      end
    end

    describe '#resource_count' do
      before do
        r = Resource.new('http://example.com/id/foo', dataset.data_graph_uri)
        r.rdf_type = 'http://example.com/types/one'
        r.save!
        r = Resource.new('http://example.com/id/bar', dataset.data_graph_uri)
        r.rdf_type = 'http://example.com/types/two'
        r.save!
        r = Resource.new('http://example.com/id/baz', dataset.data_graph_uri)
        r.rdf_type = 'http://example.com/types/three'
        r.save!
      end

      it 'should return a count of all the resources in the dataset' do
        dataset.resource_count.should == 3
      end
    end

    describe '#example_resources' do
      let!(:resource_one) do
        r = Resource.new('http://example.com/id/foo', dataset.data_graph_uri)
        r.rdf_type = 'http://example.com/types/one'
        r.save!
        r
      end

      let!(:resource_two) do
        r = Resource.new('http://example.com/id/bar', dataset.data_graph_uri)
        r.rdf_type = 'http://example.com/types/two'
        r.save!
        r
      end

      before do
        r = Resource.new('http://example.com/id/baz', dataset.data_graph_uri)
        r.rdf_type = 'http://example.com/types/two'
        r.save!
      end

      it 'should only return a single resource for each type' do
        dataset.example_resources.count.should == dataset.types.count
      end

      it 'should return an example resource for each type used in the dataset' do
        dataset.example_resources.map(&:uri).should == [resource_one.uri, resource_two.uri]
      end
    end

    describe '#ontologies' do
      let(:ontology) { FactoryGirl.create(:ontology) }
      let(:property) { ontology.properties.first }

      before do
        r = Resource.new('http://example.com/id/bar', dataset.data_graph_uri)
        r.write_predicate(property.uri, 'foo')
        r.save!
      end

      it 'should return the ontologies which we have data about that have been used in the dataset' do
        dataset.ontologies.should == [ontology]
      end
    end

    describe '#concept_schemes' do
      let(:concept_scheme) { FactoryGirl.create(:concept_scheme) }
      let(:concept) { concept_scheme.concepts.first }

      before do
        r = Resource.new('http://example.com/id/bar', dataset.data_graph_uri)
        r.write_predicate('http://example.com/is-unrelated-to', concept.uri)
        r.save!
      end

      it 'should return the concept schemes which we have data about that have been used in the dataset' do
        dataset.concept_schemes.should == [concept_scheme]
      end
    end

    describe ".uri_from_slug" do
      it "returns a uri given a slug" do
        slug = "sluggy/my-slug"
        Dataset.uri_from_slug(slug).should == "http://pmdtest.dev/data/#{slug}"
      end
    end

    describe ".slug_from_uri" do
      it "returns a slug given a uri" do
        slug = "sluggy/my-slug"
        Dataset.slug_from_uri("http://pmdtest.dev/data/#{slug}").should == slug
      end
    end

    describe ".find_by_slug" do
      it "should perform a find on the uri for the slug" do
        slug = "sluggy/my-slug"
        Dataset.should_receive(:find).with(Dataset.uri_from_slug(slug))
        Dataset.find_by_slug(slug)
      end
    end
  end
end