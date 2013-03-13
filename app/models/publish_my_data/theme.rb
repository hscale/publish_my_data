module PublishMyData
  # A theme for datasets
  class Theme

    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    class << self
      def theme_graph
        RDF::URI.new("http://#{PublishMyData.local_domain}/graph/concept-scheme/themes")
      end

      def by_slug(slug)
        Theme.where("?uri <#{RDF::SKOS.notation}> '#{slug}'").first
      end
    end

    rdf_type RDF::SITE.Theme
    graph_uri Theme.theme_graph

    field :label, RDF::RDFS.label
    field :slug, RDF::SKOS.notation
    field :description, RDF::RDFS.description

    def datasets_criteria
      Dataset.where("?uri <#{RDF::DCAT.theme}> <#{self.uri.to_s}>")
    end

    def to_param
      self.slug
    end

  end
end