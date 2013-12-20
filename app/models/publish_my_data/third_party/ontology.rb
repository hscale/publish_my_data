module PublishMyData
  module ThirdParty
    class Ontology < PublishMyData::Ontology
      delegate :comment, :description, :license, :publisher, :contact_email, to: :data_resource

      # if there's no data graph set, return the graph uri
      def data_graph_uri
        super || self.graph_uri
      end

      # Overrides
      ['to_rdf', 'to_ttl', 'to_nt', 'to_json'].each do |method_name|
        define_method method_name do |opts={}|
          resources = Resource.find_by_sparql("
            SELECT DISTINCT ?uri
            WHERE { GRAPH <#{self.data_graph_uri}> {?uri ?p ?o} }
          ")
          Tripod::ResourceCollection.new(resources).send(method_name)
        end
      end

      def local?
        false
      end

      private

      def data_resource
        @data_resource = PublishMyData::Ontology.new(self.uri, graph_uri: self.data_graph_uri)
        @data_resource.hydrate!
        @data_resource
      end
    end
  end
end