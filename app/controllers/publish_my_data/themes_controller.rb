require_dependency "publish_my_data/application_controller"

module PublishMyData
  class ThemesController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json

    def index
      # don't bother paginating this for now - there probably wont be that many themes
      @themes = Theme.all.resources
      respond_with(@themes)
    end

    def show
      @theme = Theme.by_slug(params[:id])

      if @theme
        dataset_criteria = Dataset.where("?uri <#{SITE_VOCAB.theme}> <#{@theme.uri.to_s}>")
        @pagination_params = PaginationParams.from_request(request)
        @datasets = Paginator.new(dataset_criteria, @pagination_params).paginate
        respond_with(@datasets)
      else
        raise Tripod::Errors::ResourceNotFound
      end

    end

  end
end
