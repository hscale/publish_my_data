module PublishMyData
  class ConceptSchemeRenderParams

    def initialize(resource)
      @resource = resource
      @concept_scheme = resource.as_concept_scheme
    end

    def render_params(opts={})

      if opts[:is_html]
        @concept_scheme.eager_load_predicate_triples!(:labels_only => true)
        @concept_scheme.eager_load_object_triples!(:labels_only => true)
      end

      {template: 'publish_my_data/concept_schemes/show', locals: {concept_scheme: @concept_scheme}}
    end

  end
end