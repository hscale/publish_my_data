require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json

    # /datasets/:id (where :id is the dataset 'slug')
    def show
      @dataset = Dataset.find_by_slug(params[:id])
      @types = RdfType.where('?s a ?uri').graph(@dataset.data_graph_uri).resources

      if request.format.html?
        @type_resource_counts = {}
        @types.each do |t|
          @type_resource_counts[t.uri.to_s] = Resource.where("?uri a <#{t.uri.to_s}>").count
        end
      end

      respond_with(@dataset)
    end

    # /datasets?page=2&per_page=10
    # TODO: add tag filters
    def index
      dataset_criteria = Dataset.all
      @pagination_params = PaginationParams.from_request(request)
      @datasets = Paginator.new(dataset_criteria, @pagination_params).paginate
      respond_with(@datasets)
    end

  end
end
