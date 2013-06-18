require_dependency "publish_my_data/application_controller"

module PublishMyData
  class InformationResourcesController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    include PublishMyData::Concerns::Controllers::Resource

    def show
      the_uri = "http://#{PublishMyData.local_domain}/data/#{params[:id]}"
      puts the_uri
      render_resource_with_uri(the_uri)
    end

  end

end