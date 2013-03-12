module PublishMyData
  class OntologyClassRenderParams

    def initialize(resource)
      @resource = resource
      @ontology_class = resource.as_ontology_class
    end

    def render_params(opts={})
      {template: 'publish_my_data/classes/show', locals: {ontology_class: @ontology_class}}
    end

  end
end