require_dependency "publish_my_data/application_controller"

module PublishMyData
  class InformationResourcesController < ApplicationController

    include ResourceRendering

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

  end

end