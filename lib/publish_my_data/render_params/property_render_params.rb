module PublishMyData
  class PropertyRenderParams

    def initialize(resource)
      @resource = resource
      @property = resource.as_property
    end

    def render_params(opts={})
      {template: 'publish_my_data/properties/show', locals: {property: @property}}
    end

  end
end