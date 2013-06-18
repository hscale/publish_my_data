module PublishMyData
  class OntologyRenderParams

    def initialize(resource)
      @resource = resource
      @ontology = resource.as_ontology
    end

    def render_params(opts={})

      if opts[:is_html]
        @ontology.eager_load_predicate_triples!(:labels_only => true)
        @ontology.eager_load_object_triples!(:labels_only => true)
      end

      {template: 'publish_my_data/ontologies/show', locals: {ontology: @ontology}}
    end

  end
end