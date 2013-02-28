module PublishMyData
  class Resource

    include Tripod::Resource

    field :label, RDF::RDFS.label

    # Is this resource in the host domain?
    def local?
      uri.starts_with?("http://" + PublishMyData.local_domain)
    end

    class << self

      def uri_from_host_and_doc_path(host, doc_path, format="")
        'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
      end
    end
  end

end
