require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController
    include PublishMyData::DataDownload

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    def dump
      @dataset = Dataset.find_by_slug(params[:id])
      # if we can't find a current download it's cos we haven't generated it yet since ds was modified
      # ... and we should 404.
      url = find_latest_download_url_for_resource(@dataset)
      raise Tripod::Errors::ResourceNotFound unless url

      redirect_to url
    end

    # /data?page=2&per_page=10
    def index
      dataset_criteria = Dataset.ordered_by_title
      @pagination_params = ResourcePaginationParams.from_request(request)
      @datasets = Paginator.new(dataset_criteria, @pagination_params).paginate
      respond_with(@datasets)
    end

  end
end
