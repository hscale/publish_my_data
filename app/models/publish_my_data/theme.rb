module PublishMyData
  # A theme for datasets
  class Theme

    include Tripod::Resource

    class << self
      def theme_type
        RDF::URI.new("http://#{PublishMyData.local_domain}/def/Theme")
      end

      def theme_graph
        RDF::URI.new("http://#{PublishMyData.local_domain}/def/concept-scheme/themes")
      end
    end

    rdf_type Theme.theme_type
    graph_uri Theme.theme_graph

    field :label, RDF::RDFS.label
    field :description, RDF::RDFS.description

    def datasets_criteria
      Dataset.where("?uri <#{PMD_DS.theme}> <#{self.uri.to_s}>")
    end

  end
end