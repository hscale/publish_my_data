module PublishMyData
  module DataCube
    class ObservationsController < PublishMyData::ApplicationController

      include PublishMyData::DataCubeController

      before_filter :get_dimensions, :get_pagination_params, :only => [:index]

      # GET /data/:dataset_slug/cube/observations
      # params:
      # rows_dimension = http://row-dimension-uri
      # columns_dimension = http://column-dimension-uri
      # http://locked-dimension-1-uri: http://locked-dimension-1-value-uri
      # order_by_column = http://column-uri (optional - will order by rows labels if not provided).
      # order_desc = true/false (default false)
      # page (default 1)
      # per_page (default 500, min 1, max 5000).
      def index

        respond_to do |format|
          format.json do
            render json: @cube.grid_observations(
              @page,
              @per_page,
              @rows_dimension_uri,
              @columns_dimension_uri,
              @locked_dimensions,
              params[:order_desc], # optional
              params[:order_by_column] #optional
            )
          end
          # this doesn't use the page and per page params send to the controller.
          # it returns the whole result set as one .
          format.csv do
            filename = "#{@dataset.slug.gsub("/", "|")}.csv"
            headers["Content-Type"] ||= 'text/csv'
            headers["Content-Disposition"] = "attachment; filename=\"#{filename}\""

            render :text =>@cube.csv_observations(
              @rows_dimension_uri,
              @columns_dimension_uri,
              @locked_dimensions,
              params[:order_desc], # optional
              params[:order_by_column] #optional
            )
          end

        end

      end

    end
  end
end