require_dependency "publish_my_data/application_controller"

module PublishMyData
  class InformationResourcesController < ApplicationController

    include ResourceRendering
    include DataDownload

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    # http://example.com/data/blah
    def data
      uri = "http://#{PublishMyData.local_domain}/data/#{params[:id]}"
      @resource = PublishMyData::Resource.find(uri, local: true)
      respond_with(@resource) do |format|
        format.html { render_resource(@resource) }
        format.atom { @resource.is_a?(PublishMyData::Dataset) ? render(template: template_for_resource(@resource)) : head(406) }
      end
    end

    # http://example.com/def/blah
    def def
      uri = "http://#{PublishMyData.local_domain}/def/#{params[:id]}"
      resource = PublishMyData::Resource.find(uri, local: true)
      respond_with(resource) do |format|
        format.html { render_resource(resource) }
      end
    end

    # http://example.com/def/blah/dump
    def dump
      uri = "http://#{PublishMyData.local_domain}/def/#{params[:id]}"
      resource = PublishMyData::Resource.find(uri, local: true)

      # if we can't find a current download it's cos we haven't generated it yet since ds was modified
      # ... and we should 404.
      url = find_latest_download_url_for_resource(resource)
      raise Tripod::Errors::ResourceNotFound unless url

      redirect_to url
    end
  end

end