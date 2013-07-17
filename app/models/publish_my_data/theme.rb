module PublishMyData
  # A theme for datasets
  class Theme

    include Tripod::Resource
    include BasicFeatures

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

    field :slug, RDF::SKOS.notation

    def datasets_count
      PublishMyData::SparqlQuery.new(datasets_query_str).count
    end

    def datasets_query_str
      # this is similar to the deprecation_last_query_str, but with a theme restriction
      "
      SELECT ?uri where {
        # this bit is all the non-deprecated ones
        {
          SELECT * WHERE {
            ?uri a <http://publishmydata.com/def/dataset#Dataset> .
            ?uri <#{RDF::DCAT.theme}> <#{self.uri.to_s}> . # limit to this theme
            ?uri <#{RDF::DC.title}> ?title . # select title so we can order
            MINUS {
              ?uri a <http://publishmydata.com/def/dataset#DeprecatedDataset>
            }
          }
          ORDER BY ?title
        }
        UNION
        # this bit is all the deprecated ones
        {
          SELECT * WHERE {
            ?uri a <http://publishmydata.com/def/dataset#DeprecatedDataset> .
            ?uri <#{RDF::DCAT.theme}> <#{self.uri.to_s}> . # limit to this theme
            ?uri <#{RDF::DC.title}> ?title . # select title so we can order
          }
          ORDER BY ?title
        }
      }
      "
    end

    def to_param
      self.slug
    end

  end
end