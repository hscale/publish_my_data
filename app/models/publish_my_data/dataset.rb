module PublishMyData
  class Dataset
    include Tripod::Resource
    include PublishMyData::Concerns::Models::Resource  #some common methods for resources.

    # basics
    field :title, RDF::DC.title
    field :comment, RDF::RDFS.comment #short desc
    field :description, RDF::DC.description # long desc

    # licence, owner, contact
    field :publisher, RDF::DC.publisher, :is_uri => true # value is a URI of a publisher
    field :license, RDF::DC.license, :is_uri => true # value is URI of where licence is defined.
    field :contact_email, RDF::PMD_DS.contactEmail, :is_uri => true
    # NOTE: for contact, use :publisher's foaf:mbox value (in this metadata graph).

    # quality, updates, maintenance
    field :issued, RDF::DC.issued, :datatype => RDF::XSD.dateTime # value is DateTime literal
    field :modified, RDF::DC.modified, :datatype => RDF::XSD.dateTime # value is DateTime literal
 #   field :update_periodicity, RDF::DC.accrualPeriodicity # waiting for response on what the value should be.

    # where to get it
    field :data_dump, RDF::VOID.dataDump, :is_uri => true # full download URI

     # what the data is about
    field :theme, RDF::DCAT.theme, :is_uri => true
    field :tags, RDF::DCAT.keyword, :multivalued => true # values are string literals

    # field :spatial_coverage, RDF::DC.spatial # value is a URI for region covered, e.g. England.
    # field :temporal_coverage, RDF::DC.temporal # value is a time interval URI
    # field :spatial_granularity, RDF::DC.spatial # value is class of the objects of refArea
    # field :temporal_granularity, RDF::DC.temporal # value is class of objects of refPeriod

    field :size, RDF::VOID.triples # value is integer.
    field :replaced_by, RDF::DC.isReplacedBy, is_uri: true

    rdf_type RDF::PMD_DS.Dataset

    cattr_accessor :DEPRECATED_DATASET_TYPE
    self.DEPRECATED_DATASET_TYPE = RDF::PMD_DS.DeprecatedDataset

    def slug
      Dataset.slug_from_uri(self.uri)
    end

    def data_graph_uri
      Dataset.data_graph_uri(self.slug)
    end

    def metadata_graph_uri
      Dataset.metadata_graph_uri(self.slug)
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

    def deprecated?
      self.rdf_type.include?(Dataset.DEPRECATED_DATASET_TYPE)
    end

    class << self

      def uri_from_data_graph_uri(data_graph_uri)
        data_graph_uri.to_s.gsub("/graph/", "/data/")
      end

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

      def find_by_slug(slug)
        Dataset.find(uri_from_slug(slug))
      end

      def uri_from_slug(slug)
        "http://#{PublishMyData.local_domain}/data/#{slug}"
      end

      def slug_from_uri(uri)
        root_uri = uri_from_slug('')
        uri.to_s.gsub(root_uri, '')
      end

      def ordered_datasets_criteria
        Dataset.all.where("?uri <#{RDF::DC.title}> ?title").order("?title")
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
