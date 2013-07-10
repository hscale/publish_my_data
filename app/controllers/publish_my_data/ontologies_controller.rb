require_dependency "publish_my_data/application_controller"

module PublishMyData
  class OntologiesController < ApplicationController
    include PublishMyData::DataDownload

    def dump
      @ontology = Ontology.find_by_slug(params[:id])

      # if we can't find a current download it's cos we haven't generated it yet since ds was modified
      # ... and we should 404.
      url = find_latest_download_url_for_resource(@ontology)
      raise Tripod::Errors::ResourceNotFound unless url

      redirect_to url
    end
  end
end