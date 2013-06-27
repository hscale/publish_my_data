module PublishMyData
  class PropertyRenderParams

    def initialize(resource)
      @resource = resource
      @property = resource.as_property
    end

    def render_params(opts={})

      if opts[:is_html]
        @property.eager_load_predicate_triples!(:labels_only => true)
        @property.eager_load_object_triples!(:labels_only => true)
      end

      {template: 'publish_my_data/properties/show', locals: {property: @property}}
    end

  end
end