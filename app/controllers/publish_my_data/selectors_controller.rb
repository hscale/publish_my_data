require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SelectorsController < ApplicationController
    def new
      selector = Statistics::Selector.create
      redirect_to selector_path(selector)
    end

    def show
      @selector = Statistics::Selector.find(params[:id])
      add_some_random_fragments_to(@selector)
    end

    private

    def add_some_random_fragments_to(selector)
      datasets = Dataset.data_cubes.sample(3)
      datasets.each do |dataset|
        @selector.build_fragment(random_dimensions_for_dataset(dataset))
      end
    end

    # Warning! Temporarily using PMD Enterprise code to demo stuff in the vie
    def random_dimensions_for_dataset(dataset)
      cube = dataset.cube
      dimensions = dataset.cube.dimensions
      random_dimensions = dimensions#.sample([rand(dimensions.length) + 1, 3].min)

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
