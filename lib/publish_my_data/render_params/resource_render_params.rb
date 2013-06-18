module PublishMyData
  class ResourceRenderParams

    def initialize(resource)
      @resource = resource
    end

    def render_params(opts={})

      if opts[:is_html]
        @resource.eager_load_predicate_triples!(:labels_only => true)
        @resource.eager_load_object_triples!(:labels_only => true)
      end

      {template: 'publish_my_data/resources/show', locals: {resource: @resource}}
    end

  end
end