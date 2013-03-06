module PublishMyData
  class Ontology
    include Tripod::Resource
    include PublishMyData::ResourceModule

    rdf_type RDF::OWL.Ontology
    field :label, RDF::RDFS.label

    def ontology_classes
      Resource.find_by_sparql("
        SELECT DISTINCT ?uri
        WHERE {
          {
            ?uri <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <#{self.uri}> .
            ?uri a <http://www.w3.org/2002/07/owl#Class> .
          }
          UNION
          {
            ?uri <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <#{self.uri}> .
            ?uri a <http://www.w3.org/2000/01/rdf-schema#Class>
          }
        }"
      )
    end

    def ontology_properties
      Resource.find_by_sparql("
        SELECT DISTINCT ?res ?p ?o
        WHERE {
          ?uri <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <#{self.uri}> .
          ?uri a <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
        }"
      )
    end
  end
end
