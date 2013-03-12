module PublishMyData
  class ConceptScheme
    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    rdf_type RDF::SKOS.ConceptScheme
    field :label, RDF::RDFS.label

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
