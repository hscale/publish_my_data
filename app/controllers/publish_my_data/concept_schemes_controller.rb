require_dependency "publish_my_data/application_controller"

module PublishMyData
  class ConceptSchemesController < ApplicationController
    include PublishMyData::DataDownload

    def dump
      @concept_scheme = ConceptScheme.find_by_slug(params[:id])

      # if we can't find a current download it's cos we haven't generated it yet since ds was modified
      # ... and we should 404.
      url = find_latest_download_url_for_resource(@concept_scheme)
      raise Tripod::Errors::ResourceNotFound unless url

      redirect_to url
    end
  end
end