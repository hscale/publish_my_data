module PublishMyData
  class OntologyRenderParams

    def initialize(resource)
      @resource = resource
      @ontology = resource.as_ontology
    end

    def render_params(opts={})

      @ontology.eager_load_predicate_triples!(:labels_only => true)
      @ontology.eager_load_object_triples!(:labels_only => true)

      ontology_classes = []
      ontology_properties = []

      ontology_class_resources = @ontology.ontology_classes
      ontology_property_resources = @ontology.ontology_properties

      ontology_class_resources.each do |ocr|
        ontology_class = ocr.as_ontology_class
        ontology_class.eager_load_predicate_triples!(:labels_only => true)
        ontology_class.eager_load_object_triples!(:labels_only => true)
        ontology_classes << ontology_class
      end

      ontology_property_resources.each do |opr|
        ontology_property = opr.as_property
        ontology_property.eager_load_predicate_triples!(:labels_only => true)
        ontology_property.eager_load_object_triples!(:labels_only => true)
        ontology_properties << ontology_property
      end

      {
        template: 'publish_my_data/ontologies/show',
        locals: {ontology: @ontology, ontology_classes: ontology_classes, ontology_properties: ontology_properties},
      }
    end

  end
end