module PublishMyData
  class Resource

    include Tripod::Resource
    include BasicFeatures

    field :rdf_type, RDF.type, :multivalued => true, :is_uri => true

    def self.uri_from_host_and_doc_path(host, doc_path, format="")
      'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
    end

    def theme
      dataset.theme_obj if dataset
    end

    def dataset
      Dataset.find(Dataset.uri_from_data_graph_uri(self.graph_uri)) rescue nil
    end

    # this calls render_params on the right type of RenderParams object.
    # (strategy pattern-ish).
    def render_params(request)
      render_params_class.new(self).
        render_params(
          pagination_params: ResourcePaginationParams.from_request(request)
        )
    end

    # Don't worry that these as_xxx methods look like they'll do an extra lookup.
    # In production, it'll be cached from a moment ago anyway!

    # this copies all teh data from this resource's repository into that of a new instance of the class passed in.
    def as_resource_of_class(klass)
      r = klass.new(self.uri)
      r.hydrate!(graph: self.repository_as_graph)
      r
    end

    def as_dataset
      as_resource_of_class(Dataset)
    end

    def as_ontology
      as_resource_of_class(Ontology)
    end

    def as_concept_scheme
      as_resource_of_class(ConceptScheme)
    end

    def as_concept
      as_resource_of_class(Concept)
    end

    def as_property
      as_resource_of_class(Property)
    end

    def as_ontology_class
      as_resource_of_class(OntologyClass)
    end

    def is_dataset?
      read_type_predicate.include?(RDF::PMD_DS.Dataset)
    end

    def is_ontology?
      read_type_predicate.include?(RDF::OWL.Ontology)
    end

    def is_class?
      read_type_predicate.include?(RDF::OWL.Class) || read_type_predicate.include?(RDF::RDFS.Class)
    end

    def is_property?
      read_type_predicate.include?(RDF.Property)
    end

    def is_concept_scheme?
      read_type_predicate.include?(RDF::SKOS.ConceptScheme)
    end

    def is_concept?
      read_type_predicate.include?(RDF::SKOS.Concept)
    end

    private

    def read_type_predicate
      read_predicate(RDF.type)
    end

    def render_params_class
      if self.is_dataset?
        DatasetRenderParams
      elsif self.is_ontology?
        OntologyRenderParams
      elsif self.is_class?
        OntologyClassRenderParams
      elsif self.is_property?
        PropertyRenderParams
      elsif self.is_concept_scheme?
        ConceptSchemeRenderParams
      elsif self.is_concept?
        ConceptRenderParams
      else
        ResourceRenderParams
      end
    end
  end

end
