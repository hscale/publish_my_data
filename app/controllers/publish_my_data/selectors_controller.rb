require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SelectorsController < ApplicationController
    def new
      selector = Statistics::Selector.create
      redirect_to selector_path(selector)
    end

    def show
      @selector = Statistics::Selector.find(params[:id])
      add_some_fragments_to(@selector)
    end

    private

    def add_some_fragments_to(selector)
      add_homelessness_acceptances_ethnicity_to(selector)
    end

    def add_homelessness_acceptances_ethnicity_to(selector)
      hae = "http://opendatacommunities.org/data/homelessness/homelessness-acceptances/ethnicity"

      ref_period = "http://opendatacommunities.org/def/ontology/time/refPeriod"
      ref_periods = [
        "http://reference.data.gov.uk/id/quarter/2013-Q1",
        "http://reference.data.gov.uk/id/quarter/2013-Q2",
        "http://reference.data.gov.uk/id/quarter/2013-Q3"
      ]

      ethnicity = "http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/ethnicity"
      ethnicities = [
        "http://opendatacommunities.org/def/concept/general-concepts/ethnicity/blackOrBlackBritish",
        "http://opendatacommunities.org/def/concept/general-concepts/ethnicity/asianOrAsianBritish",
        "http://opendatacommunities.org/def/concept/general-concepts/ethnicity/white"
      ]

      @selector.build_fragment(
        dataset_uri: hae,
        dimensions: [
          { dimension_uri: ref_period, dimension_values: ref_periods },
          { dimension_uri: ethnicity, dimension_values: ethnicities }
        ]
      )
    end

    # Now unused - the random data was making it really hard to see what was going on
    def add_some_random_fragments_to(selector)
      datasets = Dataset.geographical_data_cubes(selector.geography_type).sample(3)
      datasets.each do |dataset|
        @selector.build_fragment({
          dataset: dataset,
          dimensions: random_dimensions_for_dataset(dataset)
        })
      end
    end

    # Warning! Temporarily using PMD Enterprise code to demo stuff in the vie
    def random_dimensions_for_dataset(dataset)
      cube = dataset.cube
      dimensions = dataset.cube.dimensions
      random_dimensions = dimensions#.sample([rand(dimensions.length) + 1, 3].min)
      random_dimensions.reject! {|d| d[:uri] == 'http://opendatacommunities.org/def/ontology/geography/refArea'}

      random_dimensions.map { |dimension_data|
        dimension = DataCube::Dimension.new(dimension_data[:uri], cube)
        dimension_values = random_values_for_dimension(dimension)

        {
          dimension_uri: dimension.uri,
          dimension_values: dimension_values
        }
      }
    end

    # Warning! Temporarily using PMD Enterprise code to demo stuff in the vie
    def random_values_for_dimension(dimension)
      values = dimension.values
      random_values = values.sample([rand(values.length) + 1, 3].min)

      random_values.map { |value|
        { dimension_value_uri: value[:uri], dimension_value_label: value[:label] }
      }
    end
  end
end
