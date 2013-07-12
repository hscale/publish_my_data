module PublishMyData
  # A theme for datasets
  class Theme

    include Tripod::Resource
    include PublishMyData::Concerns::Models::Resource  #some common methods for resources.

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
    field :comment, RDF::RDFS.comment

    def datasets_query_str
      # this is similar to the deprecation_last_query_str, but with a theme restriction

      "
      SELECT ?uri where {
        {
          ?uri a <http://publishmydata.com/def/dataset#Dataset> .
          ?uri <#{RDF::DCAT.theme}> <#{self.uri.to_s}>
          MINUS {
          ?uri a <http://publishmydata.com/def/dataset#DeprecatedDataset>
          }
        }
        UNION
        {
          ?uri a <http://publishmydata.com/def/dataset#Dataset> .
          ?uri a <http://publishmydata.com/def/dataset#DeprecatedDataset> .
        }
      }
      "
    end

    def to_param
      self.slug
    end

  end
end