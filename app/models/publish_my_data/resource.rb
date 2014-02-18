module PublishMyData
  class Resource

    include Tripod::Resource
    include BasicFeatures

    field :rdf_type, RDF.type, :multivalued => true, :is_uri => true

    cattr_accessor :LOCAL_RESOURCES, :THIRD_PARTY_RESOURCES, :RESOURCES
    @@LOCAL_RESOURCES = [Dataset, ConceptScheme, Ontology]
    @@THIRD_PARTY_RESOURCES = [ThirdParty::Ontology, ThirdParty::ConceptScheme]
    @@RESOURCES = [Concept, OntologyClass, Property, RdfType]

    class << self
      def uri_from_host_and_doc_path(host, doc_path, format="")
        'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
      end

      alias_method :find_by_uri, :find
      def find(uri, opts={})
        resource = self.find_by_uri(uri)
        type = resource.read_predicate(RDF.type)

        if opts[:local]
          self.LOCAL_RESOURCES.each do |klass|
            return klass.find(uri) if type.include?(klass.get_rdf_type)
          end
        end
        self.THIRD_PARTY_RESOURCES.each do |klass|
          return klass.find(uri, :ignore_graph => true) if type.include?(klass.get_rdf_type)
        end
        self.RESOURCES.each do |klass|
          return klass.find(uri) if type.include?(klass.get_rdf_type)
        end
        return resource
      end
    end

    def theme
      dataset.theme_obj if dataset
    end

    def dataset
      Dataset.find(Dataset.uri_from_data_graph_uri(self.graph_uri)) rescue nil
    end

  end
end
