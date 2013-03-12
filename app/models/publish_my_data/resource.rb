module PublishMyData
  class Resource

    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    field :label, RDF::RDFS.label
    field :rdf_type, RDF.type, :multivalued => true

    def self.uri_from_host_and_doc_path(host, doc_path, format="")
      'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
    end

    def theme
      dataset.theme_obj if dataset
    end

    def dataset
      slug = Dataset.slug_from_data_graph_uri(self.graph_uri)
      Dataset.find_by_slug(slug) rescue nil
    end

    # this calls render_params on the right type of RenderParams object.
    # (strategy pattern-ish).
    def render_params(request)
      render_params_class.new(self).render_params(pagination_params: PaginationParams.from_request(request))
    end

    # Don't worry that these as_xxx methods look like they'll do an extra lookup.
    # In production, it'll be cached from a moment ago anyway!

    def as_ontology
      Ontology.find(self.uri)
    end

    def as_concept_scheme
      ConceptScheme.find(self.uri)
    end

    def as_concept
      Concept.find(self.uri)
    end

    def as_property
      Property.find(self.uri)
    end

    def as_ontology_class
      OntologyClass.find(self.uri)
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
      if self.is_ontology?
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
