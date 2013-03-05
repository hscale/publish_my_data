module PublishMyData
  # A theme for datasets
  class Theme

    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    class << self
      def theme_graph
        RDF::URI.new("http://#{PublishMyData.local_domain}/def/concept-scheme/themes")
      end
    end

    rdf_type SITE_VOCAB.Theme
    graph_uri Theme.theme_graph

    field :label, RDF::RDFS.label
    field :description, RDF::RDFS.description

    def datasets_criteria
      Dataset.where("?uri <#{SITE_VOCAB.theme}> <#{self.uri.to_s}>")
    end

  end
end