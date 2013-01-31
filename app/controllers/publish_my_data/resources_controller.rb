require_dependency "publish_my_data/application_controller"

module PublishMyData
  class ResourcesController < ApplicationController

    # /resource?uri=http://foo.bar
    def show
      uri = params[:uri]
      begin
        # try to look it up
        Resource.find(uri)
      rescue Tripod::Errors::ResourceNotFound
        # if it's not there
        respond_to do |format|
          format.html { redirect_to uri }
          # TODO: cater for other mime types
          # something like:?
          # format.any(:rdf, :ttl, :text, :nt, :json)  { render :nothing => true, :status => 404, :content_type => 'text/plain' }
        end
      end
    end

  end
end
