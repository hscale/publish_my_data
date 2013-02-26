require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json

    # /datasets/:id (where :id is the dataset 'slug')
    def show
      @dataset = Dataset.find_by_slug(params[:id])
      @types = PublishMyData::RdfType.where('?s a ?uri').graph(@dataset.data_graph_uri).resources
      respond_with(@dataset)
    end

    # /datasets?page=2&per_page=10
    # /datasets?theme=foo
    def index
      dataset_criteria = Dataset.all
      dataset_criteria = add_theme_filter(dataset_criteria)
      @datasets = paginate_resources(dataset_criteria)
      respond_with(@datasets)
    end

    private

    def add_theme_filter(criteria)
      unless params[:theme].blank?
        @theme = params[:theme]
        criteria.where("?uri <#{PMD_DS.theme}> '#{@theme}'")
      end
      criteria
    end
  end
end
