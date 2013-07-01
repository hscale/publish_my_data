module PublishMyData
  class ConceptSchemeRenderParams

    def initialize(resource)
      @resource = resource
      @concept_scheme = resource.as_concept_scheme
    end

    def render_params(opts={})

      @concept_scheme.eager_load_predicate_triples!(:labels_only => true)
      @concept_scheme.eager_load_object_triples!(:labels_only => true)

      concepts = []

      concept_resources = @concept_scheme.concepts
      concept_resources.each do |cr|
        concept = cr.as_concept
        concept.eager_load_predicate_triples!(:labels_only => true)
        concept.eager_load_object_triples!(:labels_only => true)
        concepts << concept
      end

      {
        template: 'publish_my_data/concept_schemes/show',
        locals: {concept_scheme: @concept_scheme, concepts: concepts}
      }
    end

  end
end