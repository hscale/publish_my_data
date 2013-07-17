module PublishMyData
  module DatasetPowers
    extend ActiveSupport::Concern

    included do
      include PublishMyData::AllFeatures
      field :theme, RDF::DCAT.theme, :is_uri => true
    end

    def metadata_graph_uri
      self.class.metadata_graph_uri(self.slug)
    end

    def to_param
      slug
    end

    def resources_in_dataset_criteria
      Resource.all.graph(self.data_graph_uri)
    end

    def theme_obj
      Theme.find(self.theme.to_s) rescue nil
    end

    module ClassMethods
      include PublishMyData::AllFeatures::ClassMethods

      # this is the graph that dataset metadata goes in.
      def metadata_graph_uri(slug)
        "#{data_graph_uri(slug)}/metadata"
      end

      # this is the dataset that the actual data will go in
      def data_graph_uri(slug)
        "http://#{PublishMyData.local_domain}/graph/#{slug}"
      end

      def uri_from_data_graph_uri(data_graph_uri)
        data_graph_uri.to_s.sub("/graph/", "/data/")
      end

      def uri_from_slug(slug)
        "http://#{PublishMyData.local_domain}/data/#{slug}"
      end

      # Criteria etc.

      def ordered_by_title
        all.where("?uri <#{RDF::DC.title}> ?title").order("?title")
      end

      def deprecation_last_query_str
        "
        SELECT ?uri where {
          # this bit is all the non-deprecated ones
          {
            SELECT * WHERE {
              ?uri a <http://publishmydata.com/def/dataset#Dataset> .
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
              ?uri <#{RDF::DC.title}> ?title . # select title so we can order
            }
            ORDER BY ?title
          }
        }
        "
      end
    end
  end
end