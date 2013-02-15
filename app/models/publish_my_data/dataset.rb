module PublishMyData
  class Dataset
    include Tripod::Resource

    field :title, RDF::DC.title
    field :description, RDF::DC.description

    rdf_type 'http://publishmydata.com/def/dataset#Dataset'

    def slug
      Dataset.slug_from_uri(self.uri)
    end

    class << self

      # this is the graph that dataset metadata goes in.
      def metadata_graph_uri(slug)
        "#{data_graph_uri(slug)}/metadata"
      end

      # this is the dataset that the actual data will go in
      def data_graph_uri(slug)
        site_domain = 'pmdtest.dev' # TODO: make this configurable
        "http://#{site_domain}/graph/#{slug}"
      end

      def find_by_slug(slug)
        Dataset.find(uri_from_slug(slug))
      end

      def uri_from_slug(slug)
        site_domain = 'pmdtest.dev' # TODO: make this configurable
        "http://#{site_domain}/datasets/#{slug}"
      end

      def slug_from_uri(uri)
        uri.to_s.split('/').last
      end

    end
  end
end
