module PublishMyData
  class ConceptScheme
    include Tripod::Resource
    include AllFeatures

    rdf_type RDF::SKOS.ConceptScheme
    deprecated_rdf_type 'http://publishmydata.com/def/concept-scheme#DeprecatedConceptScheme'

    def self.uri_from_slug(slug)
      "http://#{PublishMyData.local_domain}/def/#{slug}"
    end

    def concepts
      @concepts ||= Concept.find_by_sparql(
        "SELECT DISTINCT ?uri ?graph
          WHERE {
            GRAPH ?graph {
              ?uri <#{RDF::SKOS.inScheme.to_s}> <#{self.uri}> .
              ?uri a <#{RDF::SKOS.Concept.to_s}> .
          }
        }"
      )
    end

    def concepts_sorted
      ConceptScheme.sort_by_label_or_uri(concepts)
    end

    def local?
      true
    end

    def eager_load!
      super
      self.concepts.each{|c| c.eager_load!}
    end

    # Overrides
    ['to_rdf', 'to_ttl', 'to_nt', 'to_json'].each do |method_name|
      define_method method_name do |opts={}|
        resources = Resource.find_by_sparql("
          SELECT DISTINCT ?uri
          WHERE {
            { SELECT ?uri WHERE { GRAPH <#{self.graph_uri}> {?uri ?p ?o} } }
            UNION
            { SELECT ?uri WHERE { GRAPH <#{self.data_graph_uri}> {?uri ?p ?o} } }
          }
        ")
        Tripod::ResourceCollection.new(resources).send(method_name)
      end
    end
  end
end
