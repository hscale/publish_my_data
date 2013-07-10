module PublishMyData
  class Ontology
    include Tripod::Resource
    include AllFeatures

    rdf_type RDF::OWL.Ontology
    deprecated_rdf_type 'http://publishmydata.com/def/ontology#DeprecatedOntology'

    def self.uri_from_slug(slug)
      "http://#{PublishMyData.local_domain}/def/ontology/#{slug}"
    end

    def ontology_classes
      Resource.find_by_sparql("
        SELECT DISTINCT ?uri ?graph
        WHERE {
          GRAPH ?graph {
            {
              ?uri <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <#{self.uri}> .
              ?uri a <http://www.w3.org/2002/07/owl#Class> .
            }
            UNION
            {
              ?uri <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <#{self.uri}> .
              ?uri a <http://www.w3.org/2000/01/rdf-schema#Class>
            }
          }
        }"
      )
    end

    def ontology_properties
      Resource.find_by_sparql("
        SELECT DISTINCT ?uri ?graph
         WHERE {
          GRAPH ?graph {
            ?uri <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <#{self.uri}> .
            ?uri a <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
          }
        }"
      )
    end
  end
end
