module PublishMyData
  class Dataset
    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    # basics
    field :title, RDF::DC.title
    field :comment, RDF::RDFS.comment #short desc
    field :description, RDF::DC.description # long desc

    # licence, owner, contact
    field :publisher, RDF::DC.publisher # value is a URI of a publisher
    field :license, RDF::DC.license # value is URI of where licence is defined.
    # NOTE: for contact, use :publisher's foaf:mbox value (in this metadata graph).

    # quality, updates, maintenance
    field :issued, RDF::DC.issued, :datatype => RDF::XSD.dateTime # value is DateTime literal
    field :modified, RDF::DC.modified, :datatype => RDF::XSD.dateTime # value is DateTime literal
    field :update_periodicity, RDF::DC.accrualPeriodicity # waiting for response on what the value should be.

    # where to get it
    field :data_dump, RDF::VOID.dataDump # full download URI

     # what the data is about
    field :theme, RDF::DCAT.theme
    field :tags, RDF::DCAT.keyword, :multivalued => true # values are string literals

    field :spatial_coverage, RDF::DC.spatial # value is a URI for region covered, e.g. England.
    field :temporal_coverage, RDF::DC.temporal # value is a time interval URI
    field :spatial_granularity, RDF::DC.spatial # value is class of the objects of refArea
    field :temporal_granularity, RDF::DC.temporal # value is class of objects of refPeriod

    field :size, RDF::VOID.triples # value is integer.

    rdf_type RDF::PMD_DS.Dataset

    def slug
      Dataset.slug_from_uri(self.uri)
    end

    def data_graph_uri
      Dataset.data_graph_uri(self.slug)
    end

    def to_param
      slug
    end

    def resources_in_dataset_criteria
      Resource.all.graph(self.data_graph_uri)
    end

    def resources_count
      resources_in_dataset_criteria.count
    end

    def theme_obj
      Theme.find(self.theme) rescue nil
    end

    # use :publisher's foaf:mbox value (in this metadata graph).
    def contact_email
      publisher_obj = Resource.find(self.publisher) if publisher
      publisher_obj.read_predicate(RDF::FOAF.mbox).first if publisher_obj
    end

    class << self

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

      def slug_from_data_graph_uri(data_graph_uri)
        data_graph_uri.to_s.split("/").last
      end
    end
  end
end
