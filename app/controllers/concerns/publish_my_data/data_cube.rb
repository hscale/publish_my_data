module PublishMyData
  module DataCubeController
    extend ActiveSupport::Concern

    included do
      respond_to :json
      before_filter :get_dataset

      private

      def get_dataset
        @dataset = Dataset.find_by_slug(params[:id])
        raise Tripod::Errors::ResourceNotFound unless @dataset.is_cube?
        @cube = @dataset.cube
      end

      def get_pagination_params
        @page = (params[:page] || 1).to_i
        @page = 1 if @page < 1

        @per_page = (params[:per_page] || 500).to_i
        @per_page = 1 if @per_page < 1
        @per_page = 5000 if @per_page > 5000
      end

      def get_dimensions
        @rows_dimension_uri = params[:rows_dimension]
        @columns_dimension_uri = params[:columns_dimension]

        @locked_dimensions = {}

        params.each_pair do |k,v|
          if k.to_s.starts_with?("http://")
            @locked_dimensions[k] = v
          end
        end
      end

    end

  end
end
