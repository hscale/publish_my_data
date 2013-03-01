module PublishMyData
  class Dataset
    include Tripod::Resource

    field :title, RDF::DC.title
    field :description, RDF::DC.description
    field :theme, PMD_DS.theme

    rdf_type PMD_DS.Dataset

    def slug
      Dataset.slug_from_uri(self.uri)
    end

    def data_graph_uri
      Dataset.data_graph_uri(self.slug)
    end

    def to_param
      slug
    end

    class << self

      def by_theme_criteria(theme)
        Dataset.where("?uri <#{PMD_DS.theme}> '#{theme}'")
      end

      def count_by_theme(theme)
        by_theme_criteria(theme).count
      end

      def by_theme(theme)
        by_theme_criteria(theme).resources
      end

      # this is the graph that dataset metadata goes in.
      def metadata_graph_uri(slug)
        "#{data_graph_uri(slug)}/metadata"
      end

      # this is the dataset that the actual data will go in
      def data_graph_uri(slug)
        "http://#{PublishMyData.local_domain}/graph/#{slug}"
      end

      def find_by_slug(slug)
        Dataset.find(uri_from_slug(slug))
      end

      def uri_from_slug(slug)
        "http://#{PublishMyData.local_domain}/datasets/#{slug}"
      end

      def slug_from_uri(uri)
        uri.to_s.split('/').last
      end

    end
  end
end
