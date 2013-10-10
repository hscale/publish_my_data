require_dependency "publish_my_data/application_controller"

module PublishMyData
  class FragmentsController < ApplicationController
    before_filter :get_selector, only: [ :datasets, :new, :create, :destroy ]
    before_filter :get_dataset, only:  [ :new, :create ]

    def datasets
      @datasets = Dataset.geographical_data_cubes(@selector.geography_type)
      
      respond_to do |format|
        format.html { render layout: false }
        format.js
      end
    end

    def new
      @dimensions = DataCube::Cube.new(@dataset).dimension_objects
      @dimensions.reject! {|d| d.uri == 'http://opendatacommunities.org/def/ontology/geography/refArea'}

      respond_to do |format|
        format.js
      end
    end

    def create
      dimensions = dimensions_from_params(params[:dataset_dimensions])

      # The Data Cube spec permits multiple measures per observation:
      # http://www.w3.org/TR/vocab-data-cube/#dsd-mm-obs
      # PMD currently only supports one measure property in a cube,
      # so we currently just pick the first available. This sort of
      # policy shouldn't live in a controller, but we'd need to
      # restructure the code a lot to give it a proper home.
      observation_source = Statistics::ObservationSource.new(dataset_uri: @dataset_uri)
      measure_property_uri = observation_source.measure_property_uris.first

      @selector.build_fragment(
        dataset_uri:          @dataset.uri,
        measure_property_uri: measure_property_uri,
        dimensions:           dimensions
      )

      if @selector.save
        redirect_to selector_path(@selector)
      end
    end

    def destroy
      @selector.remove_fragment(params[:index].to_i)

      if @selector.save
        redirect_to selector_path(@selector)
      end
    end

    private

    def get_selector
      @selector = Statistics::Selector.find(params[:selector_id])
    end

    def get_dataset
      @dataset = Dataset.find(params[:dataset_uri])
    end

    def dimensions_from_params(dimension_params)
      dimension_params.keys.map do |uri|
        dimension_values = dimension_params[uri].split(', ')
        {
          dimension_uri: uri,
          dimension_values: dimension_values.present? ? dimension_values : all_dimensions[uri]
        }
      end
    end

    def all_dimensions
      all_dimensions = params[:all_dataset_dimensions]
      all_dimensions.keys.inject({}) do |dimensions_map, dimension_uri|
        dimensions_map[dimension_uri] = all_dimensions[dimension_uri].split(', ')
        dimensions_map
      end
    end
  end
end
