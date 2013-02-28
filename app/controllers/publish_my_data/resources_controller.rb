require_dependency "publish_my_data/application_controller"

module PublishMyData
  class ResourcesController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json

    # /resources
    # /resources?type=[http://type-uri]&dataset=[dataset-slug]
    def index
      resource_criteria = Resource.all

      # TODO: when we get more complicated fitlers, move this out somewhere else.
      resource_criteria = add_type_filter(resource_criteria)
      resource_criteria = add_dataset_filter(resource_criteria)

      @resources = paginate_resources(resource_criteria)
      respond_with(@resources)
    end

    # /resource?uri=http://foo.bar
    def show
      uri = params[:uri]
      begin
        # try to look it up
        @resource = Resource.find(uri)
        eager_load_labels()
        respond_with(@resource)
      rescue Tripod::Errors::ResourceNotFound
        # if it's not there
        respond_to do |format|
          format.html { redirect_to uri }
          # This is meant for UI browsing only, really. Just 404 for other mimes.
          format.any { render :nothing => true, :status => 404, :content_type => 'text/plain' }
        end
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
      @resource = Resource.find(uri)
      eager_load_labels() if request.format.html?

      # TODO: special views like ontology, dataset, etc?
      respond_with(@resource) do |format|
        format.html { render :template => 'publish_my_data/resources/show' }
      end
    end

    # http://example.com/def/blah
    def definition
      uri = 'http://' + request.host + '/def/' + params[:path]
      @resource = Resource.find(uri)
      eager_load_labels() if request.format.html?

      # TODO: special views like ontology, dataset, etc?
      respond_with(@resource) do |format|
        format.html { render :template => 'publish_my_data/resources/show' }
      end
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

    def eager_load_labels
      @resource.eager_load_predicate_triples!
      @resource.eager_load_object_triples!
    end

  end


end
