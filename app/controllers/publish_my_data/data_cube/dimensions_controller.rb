module PublishMyData
  module DataCube
    class DimensionsController < PublishMyData::ApplicationController

      include PublishMyData::DataCubeController

      before_filter :get_dimension, :only => [:values, :size]
      before_filter :get_dimensions, :only => [:row_labels]
      before_filter :get_pagination_params, :only => [:row_labels]

      # list the dimensions for the cube
      # GET /data/:dataset_slug/cube/dimensions(.:format)
      def index
        respond_with @cube.dimensions
      end

      # the measure property for the cube
      # GET /data/:dataset_slug/cube/measure(.:format)
      def measure
        respond_with @cube.measure_property
      end
      
      # GET /data/:dataset_slug/cube/area_dimension(.:format)
      def area_dimension
        respond_with @cube.area_dimension
      end

      # all values for a single dimension in the cube.
      # Useful for getting axes data for cube grids.
      # GET /data/:dataset_slug/cube/dimension_values(.:format)
      # Note: supply dimension parameter on query string
      # e.g. /data/additional-affordable-dwellings/cube/dimension_values.json?dimension=http%3A%2F%2Fopendatacommunities.org%2Fdef%2Fhousing%2FaffordableHousingType
      def values
        respond_with @dimension.values
      end

      # size of a dimension - JSON only.
      # GET /data/:dataset_slug/cube/dimension_size(.:format)
      # Note: supply dimension parameter on query string
      # e.g. /data/additional-affordable-dwellings/cube/dimension_values.ttl?dimension=http%3A%2F%2Fopendatacommunities.org%2Fdef%2Fhousing%2FaffordableHousingType
      def size
        respond_to do |format|
          format.json { render :json => {:size => @dimension.size } }
        end
      end

      # recommended starting columns
      def recommended
        respond_to do |format|
          format.json { render :json => @cube.recommended_dimensions}
        end
      end

      private

      def get_dimension
        @dimension = Dimension.new(params[:dimension], @cube)
      end

    end
  end
end