module PublishMyData
  class Resource

    include Tripod::Resource

    field :label, RDF::RDFS.label

    # Is this resource in our domain?
    def local?
      # TODO: parameterize!
      uri.starts_with?("http://pmd.dev")
    end

    class << self

      def uri_from_host_and_doc_path(host, doc_path, format="")
        'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
      end
    end
  end

end
