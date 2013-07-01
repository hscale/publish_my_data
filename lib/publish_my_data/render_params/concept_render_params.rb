module PublishMyData
  class ConceptRenderParams

    def initialize(resource)
      @resource = resource
      @concept = resource.as_concept
    end

    def render_params(opts={})

      @concept.eager_load_predicate_triples!(:labels_only => true)
      @concept.eager_load_object_triples!(:labels_only => true)

      {template: 'publish_my_data/concepts/show', locals: {concept: @concept}}
    end

  end
end