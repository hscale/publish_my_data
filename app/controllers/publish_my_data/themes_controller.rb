require_dependency "publish_my_data/application_controller"

module PublishMyData
  class ThemesController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json

    def index
      # don't bother paginating this for now - there probably wont be that many
      @themes = Theme.all.resources

      respond_with(@themes)
    end

  end
end
