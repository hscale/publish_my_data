module PublishMyData
  class Resource

    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    field :label, RDF::RDFS.label

    # this calls render_params on the right type of RenderParams object.
    # (strategy pattern-ish).
    def render_params(request)
      render_params_class.new(self).render_params(pagination_params: PaginationParams.from_request(request))
    end

    # Don't worry that these as_xxx methods look like they'll do an extra lookup.
    # In production, it'll be cached from a moment ago anyway!

    def as_theme
      Theme.find(self.uri)
    end

    def as_ontology
      Ontology.find(self.uri)
    end

    def as_concept_scheme
      ConceptScheme.find(self.uri)
    end

    def is_theme?
      read_type_predicate.include?(SITE_VOCAB.Theme)
    end

    def is_ontology?
      read_type_predicate.include?(RDF::OWL.Ontology)
    end

    def is_concept_scheme?
      read_type_predicate.include?(RDF::SKOS.ConceptScheme)
    end

    def self.uri_from_host_and_doc_path(host, doc_path, format="")
      'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
    end

    private

    def read_type_predicate
      read_predicate(RDF.type)
    end

    def render_params_class
      if self.is_theme?
        ThemeRenderParams
      elsif self.is_ontology?
        OntologyRenderParams
      elsif self.is_concept_scheme?
        ConceptSchemeRenderParams
      else
        ResourceRenderParams
      end
    end
  end

end
