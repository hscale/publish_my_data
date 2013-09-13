require_dependency "publish_my_data/application_controller"

module PublishMyData
  class InformationResourcesController < ApplicationController

    include ResourceRendering

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    # http://example.com/data/blah
    def data
      uri = "http://#{PublishMyData.local_domain}/data/#{params[:id]}"
      resource = PublishMyData::Resource.find(uri, local: true)
      render_resource(resource)
    end

    # http://example.com/def/blah
    def def
      uri = "http://#{PublishMyData.local_domain}/def/#{params[:id]}"
      resource = PublishMyData::Resource.find(uri, local: true)
      render_resource(resource)
    end

  end

end