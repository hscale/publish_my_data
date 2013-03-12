module PublishMyData
  class ConceptRenderParams

    def initialize(resource)
      @resource = resource
      @concept = resource.as_concept
    end

    def render_params(opts={})
      {template: 'publish_my_data/concepts/show', locals: {concept: @concept}}
    end

  end
end