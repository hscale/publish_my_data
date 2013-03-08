module PublishMyData
  class ConceptScheme
    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    rdf_type RDF::SKOS.ConceptScheme
    field :label, RDF::RDFS.label

    def concepts
      Resource.find_by_sparql(
        "SELECT DISTINCT ?uri ?graph WHERE { GRAPH ?graph {<#{self.uri}> <http://www.w3.org/2004/02/skos/core#hasTopConcept> ?uri }}"
      )
    end
  end
end
