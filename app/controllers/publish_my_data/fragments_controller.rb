require_dependency "publish_my_data/application_controller"

module PublishMyData
  class FragmentsController < ApplicationController
    before_filter :get_selector, only: [ :datasets, :new, :create ]
    before_filter :get_dataset, only:  [ :new, :create ]

    def datasets
      @datasets = Dataset.geographical_data_cubes(@selector.geography_type)
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
      @selector.build_fragment({
        dataset_uri: @dataset.uri,
        dimensions: dimensions
      })

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
        {
          dimension_uri: uri,
          dimension_values: dimension_params[uri].keys
        }
      end
    end
  end
end
