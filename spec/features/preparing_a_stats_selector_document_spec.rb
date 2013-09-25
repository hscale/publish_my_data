require 'spec_helper'

module PublishMyData
  describe "Preparing a Stats Selector document", type: :feature do
    describe "making a new selector" do
      UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

      specify "visiting the new selector path currently creates a selector for you" do
        visit "/selectors/new"

        expect(page.current_path).to match(%r{^/selectors/(.*)})
        expect(
          %r{^/selectors/(.*)}.match(page.current_path)[1]
        ).to match(UUID_REGEX)
      end
    end

    describe "adding a dataset" do
      let(:geography_type) { "http://statistics.data.gov.uk/def/statistical-geography" }
      let(:peterborough_uri) { "http://statistics.data.gov.uk/id/statistical-geography/E06000031" }

      let(:peterborough) { Resource.new(peterborough_uri, "http://example.com/geography") }

      let(:dataset_a) { FactoryGirl.create(:dataset, title: "Dataset A", slug: "dataset-a") }
      let(:dataset_b) { FactoryGirl.create(:dataset, title: "Dataset B", slug: "dataset-b") }

      let(:observation_a_1) {
        Resource.new('http://example.com/observation-a-1', dataset_a.data_graph_uri)
      }

      let(:observation_b_1) {
        Resource.new('http://example.com/observation-b-1', dataset_b.data_graph_uri)
      }

      before(:each) do
        peterborough.rdf_type = geography_type
        peterborough.save!
      end

      before(:each) do
        observation_a_1.write_predicate(RDF::CUBE.dataSet, RDF::URI.new(dataset_a.uri))
        observation_a_1.write_predicate(
          RDF::URI.new("http://opendatacommunities.org/def/ontology/geography/refArea"),
          RDF::URI.new(peterborough_uri)
        )
        observation_a_1.save!

        observation_b_1.write_predicate(RDF::CUBE.dataSet, RDF::URI.new(dataset_b.uri))
        observation_b_1.write_predicate(
          RDF::URI.new("http://opendatacommunities.org/def/ontology/geography/refArea"),
          RDF::URI.new(peterborough_uri)
        )
        observation_b_1.save!
      end

      before(:each) do
        visit "/selectors/new"
        click_link "Add Data"
      end

      it "lists the datasets" do
        save_and_open_page
        expect(page).to have_select("Dataset", options: ["Dataset A", "Dataset B"])
      end
    end
  end
end
