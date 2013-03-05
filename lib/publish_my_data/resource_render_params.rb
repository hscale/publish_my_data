module PublishMyData
  class ResourceRenderParams

    def initialize(resource)
      @resource = resource
    end

    def render_params(opts={})
      {template: 'publish_my_data/resources/show', locals: {resource: @resource}}
    end

  end
end