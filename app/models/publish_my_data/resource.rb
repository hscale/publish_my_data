module PublishMyData
  class Resource

    include Tripod::Resource
    include BasicFeatures

    field :rdf_type, RDF.type, :multivalued => true, :is_uri => true

    cattr_accessor :LOCAL_RESOURCES, :THIRD_PARTY_RESOURCES, :RESOURCES
    @@LOCAL_RESOURCES = [ConceptScheme, Ontology]
    @@THIRD_PARTY_RESOURCES = [ThirdParty::Ontology, ThirdParty::ConceptScheme]
    @@RESOURCES = [Dataset, Concept, OntologyClass, Property, RdfType]

    class << self
      def uri_from_host_and_doc_path(host, doc_path, format="")
        'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
      end

      alias_method :find_by_uri, :find
      def find(uri, opts={})
        resource = self.find_by_uri(uri)
        type = resource.read_predicate(RDF.type)

        resource_klasses = opts.fetch(:local, false) ? self.LOCAL_RESOURCES : self.THIRD_PARTY_RESOURCES
        resource_klasses.each do |klass|
          return klass.find(uri) if type.include?(klass.get_rdf_type)
        end
        self.RESOURCES.each do |klass|
          return klass.find(uri, :ignore_graph => true) if type.include?(klass.get_rdf_type)
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

    def human_readable_label
      label #TODO fall back to other name-like predicates
    end

    def human_readable_name
      human_readable_label || uri.to_s
    end

    def human_readable_name_is_uri?
      human_readable_label ? false : true;
    end

  end
end
