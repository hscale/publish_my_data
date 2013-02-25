require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    before_filter :get_pagination_params, :only => [:index]

    respond_to :html, :ttl, :rdf, :nt, :json

    # /datasets/:id (where :id is the dataset 'slug')
    def show
      @dataset = Dataset.find_by_slug(params[:id])
      respond_with(@dataset)
    end

    # /datasets?_page=2&_per_page=10
    def index
      @datasets = paginate_resources(Dataset.all)
      respond_with(@datasets)
    end

  end
end
