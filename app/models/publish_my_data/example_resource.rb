module PublishMyData
  class ExampleResource
    include Tripod::Resource
    include BasicFeatures

    field :rdf_types, RDF.type, is_uri: true, multivalued: true

    def eager_load!
      eager_load_predicate_triples!
      eager_load_object_triples!
    end

    def rdf_type_as_resource
      get_related_resource(self.rdf_type, Resource)
    end

    def as_ttl
      graph = RDF::Graph.new
      repository.query( [@uri, :predicate, :object] ) do |statement|
        graph << statement
      end
      graph.dump(:ttl)
    end
  end
end