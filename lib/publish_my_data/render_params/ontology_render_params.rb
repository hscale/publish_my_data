module PublishMyData
  class OntologyRenderParams

    def initialize(resource)
      @resource = resource
      @ontology = resource.as_ontology
    end

    def render_params(opts={})
      {template: 'publish_my_data/ontologies/show', locals: {ontology: @ontology}}
    end

  end
end