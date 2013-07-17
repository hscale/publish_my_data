require_dependency "publish_my_data/application_controller"

module PublishMyData
  class InformationResourcesController < ApplicationController

    include ResourceRendering
    include DataDownload

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    # http://example.com/data/blah
    def data
      uri = "http://#{PublishMyData.local_domain}/data/#{params[:id]}"
      render_resource_with_uri(uri)
    end

    # http://example.com/def/blah
    def def
      uri = "http://#{PublishMyData.local_domain}/def/#{params[:id]}"
      render_resource_with_uri(uri)
    end

    def dump
      uri = "http://#{PublishMyData.local_domain}/def/#{params[:id]}"
      @resource = Resource.find_type(uri)
      # if we can't find a current download it's cos we haven't generated it yet since ds was modified
      # ... and we should 404.
      url = find_latest_download_url_for_resource(@resource)
      raise Tripod::Errors::ResourceNotFound unless url

      redirect_to url
    end
  end

end