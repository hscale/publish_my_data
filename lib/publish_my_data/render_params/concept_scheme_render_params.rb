module PublishMyData
  class ConceptSchemeRenderParams

    def initialize(resource)
      @resource = resource
      @concept_scheme = resource.as_concept_scheme
    end

    def render_params(opts={})
      {template: 'publish_my_data/concept_schemes/show', locals: {concept_scheme: @concept_scheme}}
    end

  end
end