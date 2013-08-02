require_dependency "publish_my_data/application_controller"

module PublishMyData
  class ResourcesController < ApplicationController

    include ResourceRendering

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    # /resources
    # /resources?type=[http://type-uri]&dataset=[dataset-slug]
    def index
      resource_criteria = Resource.all

      # TODO: when we get more complicated fitlers, move this out somewhere else.
      resource_criteria = add_type_filter(resource_criteria)
      resource_criteria = add_dataset_filter(resource_criteria)

      @pagination_params = ResourcePaginationParams.from_request(request)
      @resources = Paginator.new(resource_criteria, @pagination_params).paginate

      respond_with(@resources)
    end

    # /resource?uri=http://foo.bar
    def show
      # RubyProf.start

      uri = params[:uri]

      if uri.present?
        begin
          resource = PublishMyData::Resource.find(uri, local: uri.starts_with?('http://' + PublishMyData.local_domain))
          render_resource(resource)
        rescue Tripod::Errors::ResourceNotFound
          # if it's not there
          respond_to do |format|
            format.html { redirect_to uri }
            # This is meant for UI browsing only, really. Just 404 for other mimes.
            format.any { render :nothing => true, :status => 404, :content_type => 'text/plain' }
          end
        end
      else
        raise Tripod::Errors::ResourceNotFound.new
      end
    end

    # linked data dereferencing:
    # for id's just redirect to the doc.
    # http://example.com/id/blah
    def id
      respond_to do |format|
        format.any(:html, :rdf, :ttl, :nt, :json) do |format|
          redirect_to "/doc/#{params[:path]}", :status=> 303
        end
      end
    end

    # http://example.com/doc/blah
    def doc
      uri = Resource.uri_from_host_and_doc_path(request.host, params[:path], params[:format])
      resource = PublishMyData::Resource.find(uri)
      render_resource(resource)
    end

    private

    # TODO: move the filter management into an object
    def add_type_filter(criteria)
      unless params[:type_uri].blank?
        @type_filter = params[:type_uri]
        @type = RdfType.find(@type_filter) rescue nil
        criteria.where("?uri a <#{@type_filter}>")
      end
      criteria
    end

    def add_dataset_filter(criteria)
      unless params[:dataset].blank?
        @dataset_filter = params[:dataset]
        @dataset = Dataset.find_by_slug(@dataset_filter) rescue nil
        criteria.graph(Dataset.data_graph_uri(@dataset_filter))
      end
      criteria
    end

  end


end
