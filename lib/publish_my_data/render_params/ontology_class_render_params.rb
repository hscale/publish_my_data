module PublishMyData
  class OntologyClassRenderParams

    def initialize(resource)
      @resource = resource
      @ontology_class = resource.as_ontology_class
    end

    def render_params(opts={})

      if opts[:is_html]
        @ontology_class.eager_load_predicate_triples!(:labels_only => true)
        @ontology_class.eager_load_object_triples!(:labels_only => true)
      end

      {template: 'publish_my_data/classes/show', locals: {ontology_class: @ontology_class}}
    end

  end
end