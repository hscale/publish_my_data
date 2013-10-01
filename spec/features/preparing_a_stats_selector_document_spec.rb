require 'spec_helper'

module PublishMyData
  describe "Preparing a Stats Selector document", type: :feature, js: true do
    let(:geography_type) { 'http://statistics.data.gov.uk/def/statistical-geography' }
    let(:peterborough_uri) { 'http://statistics.data.gov.uk/id/statistical-geography/E06000031' }
    let(:peterborough) { Resource.new(peterborough_uri, "http://example.com/geography") }

    before(:each) do
      peterborough.rdf_type = geography_type
      peterborough.save!
    end

    describe "making a new selector" do
      UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

      xspecify "visiting the new selector path currently creates a selector for you" do
        visit "/selectors/new"

        expect(page.current_path).to match(%r{^/selectors/(.*)})
        expect(
          %r{^/selectors/(.*)}.match(page.current_path)[1]
        ).to match(UUID_REGEX)
      end
    end

    describe "adding a dataset" do
      let(:dataset_a) { FactoryGirl.create(:dataset, title: "Dataset A", slug: "dataset-a") }
      let(:dataset_b) { FactoryGirl.create(:dataset, title: "Dataset B", slug: "dataset-b") }

      let(:observation_a_1) {
        Resource.new('http://example.com/observation-a-1', dataset_a.data_graph_uri)
      }

      let(:observation_b_1) {
        Resource.new('http://example.com/observation-b-1', dataset_b.data_graph_uri)
      }

      before(:each) do
        observation_a_1.write_predicate(RDF::CUBE.dataSet, RDF::URI.new(dataset_a.uri))
        observation_a_1.write_predicate(
          RDF::URI.new('http://opendatacommunities.org/def/ontology/geography/refArea'),
          RDF::URI.new(peterborough_uri)
        )
        observation_a_1.save!

        observation_b_1.write_predicate(RDF::CUBE.dataSet, RDF::URI.new(dataset_b.uri))
        observation_b_1.write_predicate(
          RDF::URI.new('http://opendatacommunities.org/def/ontology/geography/refArea'),
          RDF::URI.new(peterborough_uri)
        )
        observation_b_1.save!
      end

      before(:each) do
        visit "/selectors/new"
        click_link "Add Data"
      end

      xit "lists the datasets" do
        expect(page).to have_select("Dataset", options: ["Dataset A", "Dataset B"])
      end
    end

    describe "selecting dimension property values" do
      let!(:dataset) {
        FactoryGirl.create(:dataset,
          title: "Homelessness Acceptances, District By Ethnicity",
          slug: "homelessness-acceptances"
        )
      }

      let(:area_1) { peterborough_uri }

      def create_dimension_property_resource(attributes)
        Resource.new(attributes.fetch(:uri), 'http://example.com/vocabs').tap do |resource|
          resource.rdf_type = 'http://purl.org/linked-data/cube#DimensionProperty'
          resource.label = attributes.fetch(:label)
          resource.save!
        end
      end

      # Dimension properties
      # The Reference Area dimension property is excluded from the fragment builder
      # because it's always used for row values
      let!(:ref_area_resource) {
        create_dimension_property_resource(
          label:  "Reference Area",
          uri:    'http://opendatacommunities.org/def/ontology/geography/refArea'
        )
      }
      let!(:ref_period_resource) {
        create_dimension_property_resource(
          label:  "Reference period",
          uri:    'http://opendatacommunities.org/def/ontology/time/refPeriod'
        )
      }
      let!(:ethnicity_resource) {
        create_dimension_property_resource(
          label:  "Ethnicity",
          uri:    'http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/ethnicity'
        )
      }

      let(:ref_period_1) { 'http://reference.data.gov.uk/id/quarter/2013-Q1' }
      let(:ref_period_2) { 'http://reference.data.gov.uk/id/quarter/2013-Q2' }

      let(:ethnicity_1) { 'http://opendatacommunities.org/def/concept/general-concepts/ethnicity/white' }
      let(:ethnicity_2) { 'http://opendatacommunities.org/def/concept/general-concepts/ethnicity/mixed' }

      before(:each) do
        label_dimension_values(
          ref_period_1: "2013-Q1",
          ref_period_2: "2013-Q2",
          ethnicity_1:  "White",
          ethnicity_2:  "Mixed"
        )
      end

      def label_dimension_values(dimension_labels)
        dimension_labels.each do |dimension_property_name, label|
          Resource.new(send(dimension_property_name), 'http://example.com/vocabs').tap do |value|
            value.label = label
            value.save!
          end
        end
      end

      let(:measure_property) { 'http://opendatacommunities.org/def/ontology/homelessness/homelessnessAcceptancesObs' }

      let(:observation_data) {
        {
          area_1: {
            ref_period_1: { ethnicity_1: 10, ethnicity_2: 20 },
            ref_period_2: { ethnicity_1: 30, ethnicity_2: 40 }
          }
        }
      }

      let!(:observations) { turn_observation_data_into_resources }

      def turn_observation_data_into_resources
        observation_data.each do |area_name, time_series_data|
          time_series_data.each do |ref_period_name, ethnicity_data|
            ethnicity_data.each do |ethnicity_name, measure|
              observation = Resource.new(
                "http://example.com/observation-#{area_name}-#{ref_period_name}-#{ethnicity_name}",
                dataset.data_graph_uri
              )

              observation.write_predicate(RDF::CUBE.dataSet, RDF::URI.new(dataset.uri))

              # The Dimension Properties
              observation.write_predicate(
                RDF::URI.new('http://opendatacommunities.org/def/ontology/geography/refArea'),
                RDF::URI.new(send(area_name))
              )
              observation.write_predicate(
                RDF::URI.new('http://opendatacommunities.org/def/ontology/time/refPeriod'),
                RDF::URI.new(send(ref_period_name))
              )
              observation.write_predicate(
                RDF::URI.new('http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/ethnicity'),
                RDF::URI.new(send(ethnicity_name))
              )

              # The Measure Property
              observation.write_predicate(
                RDF::URI.new('http://opendatacommunities.org/def/ontology/homelessness/homelessnessAcceptancesObs'),
                measure
              )

              observation.save!
            end
          end
        end
      end

      before(:each) do
        visit "/selectors/new"
        click_link "Add Data"
        select "Homelessness Acceptances, District By Ethnicity", from: "Dataset"
        click_button "choose"
      end

      xit "lists the datasets" do
        expect(page).to have_content("Ethnicity")
        expect(page).to have_checked_field("Mixed")
        expect(page).to have_checked_field("White")

        expect(page).to have_content("Reference period")
        expect(page).to have_checked_field("2013-Q1")
        expect(page).to have_checked_field("2013-Q2")

        expect(page).to have_button("Go")
      end
    end
  end
end
