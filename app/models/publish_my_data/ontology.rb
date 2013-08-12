module PublishMyData
  class Ontology
    include Tripod::Resource
    include AllFeatures

    rdf_type RDF::OWL.Ontology
    deprecated_rdf_type 'http://publishmydata.com/def/ontology#DeprecatedOntology'

    def self.uri_from_slug(slug)
      "http://#{PublishMyData.local_domain}/def/#{slug}"
    end

    def classes
      @classes ||= OntologyClass.find_by_sparql("
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

    def properties
      @properties ||= Property.find_by_sparql("
        SELECT DISTINCT ?uri ?graph
         WHERE {
          GRAPH ?graph {
            ?uri <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> <#{self.uri}> .
            ?uri a <http://www.w3.org/1999/02/22-rdf-syntax-ns#Property> .
          }
        }"
      )
    end

    def local?
      true
    end

    def eager_load!
      super
      classes.each{|c| c.eager_load!}
      properties.each{|p| p.eager_load!}
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
