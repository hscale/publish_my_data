module PublishMyData
  class ConceptScheme
    include Tripod::Resource
    include AllFeatures

    rdf_type RDF::SKOS.ConceptScheme
    deprecated_rdf_type 'http://publishmydata.com/def/concept-scheme#DeprecatedConceptScheme'

    def self.uri_from_slug(slug)
      "http://#{PublishMyData.local_domain}/def/concept-scheme/#{slug}"
    end

    def concepts
      Resource.find_by_sparql(
        "SELECT DISTINCT ?uri ?graph
          WHERE {
            GRAPH ?graph {
              ?uri <#{RDF::SKOS.inScheme.to_s}> <#{self.uri}> .
              ?uri a <#{RDF::SKOS.Concept.to_s}> .
          }
        }"
      )
    end
  end
end
