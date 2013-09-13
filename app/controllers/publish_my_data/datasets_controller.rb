require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    # /data?page=2&per_page=10
    def index
      @pagination_params = ResourcePaginationParams.from_request(request)
      @datasets = Paginator.new(Dataset.deprecation_last_query_str, @pagination_params, resource_class: PublishMyData::Dataset).paginate
      respond_with(@datasets)
    end

  end
end
