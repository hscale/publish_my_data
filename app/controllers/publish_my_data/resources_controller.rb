require_dependency "publish_my_data/application_controller"

module PublishMyData
  class ResourcesController < ApplicationController

    # /resource?uri=http://foo.bar
    def show
      uri = params[:uri]
      begin
        # try to look it up
        @resource = Resource.find(uri)
      rescue Tripod::Errors::ResourceNotFound
        # if it's not there
        respond_to do |format|
          format.html { redirect_to uri }
          # This is meant for UI browsing only, really. Just 404 for other mimes.
          format.any(:rdf, :ttl, :text, :nt, :json)  { render :nothing => true, :status => 404, :content_type => 'text/plain' }
        end
      end
    end

    # linked data dereferencing:
    # for id's just redirect to the doc.
    def id
      respond_to do |format|
        format.any(:html, :rdf, :ttl, :text, :nt, :json) do |format|
          redirect_to "/doc/#{params[:path]}", :status=> 303
        end
      end
    end

    # http://example.com/doc/blah
    def doc
      # swap doc for id in the url to arrive at the uri
      uri = req.sub(/\/doc\//,'/id/').split('?')[0].sub(/\.#{params[:format]}$/,'')
      @resource = Resource.find(uri)

      respond_to do |format|
        format.html
        # TODO: other views like ontology, dataset, etc?

        # TODO: other mime types.
      end
    end


    # http://example.com/def/blah
    def definition
      # TODO
    end

  end
end
