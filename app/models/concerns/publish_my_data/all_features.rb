module PublishMyData
  module AllFeatures
    extend ActiveSupport::Concern

    included do
      include PublishMyData::BasicFeatures

      # basics
      field :title, RDF::DC.title
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
      field :tags, RDF::DCAT.keyword, :multivalued => true # values are string literals

      # field :spatial_coverage, RDF::DC.spatial # value is a URI for region covered, e.g. England.
      # field :temporal_coverage, RDF::DC.temporal # value is a time interval URI
      # field :spatial_granularity, RDF::DC.spatial # value is class of the objects of refArea
      # field :temporal_granularity, RDF::DC.temporal # value is class of objects of refPeriod

      field :size, RDF::VOID.triples # value is integer.
      field :replaced_by, RDF::DC.isReplacedBy, is_uri: true

      cattr_accessor :_DEPRECATED_RDF_TYPE
    end

    def deprecated?
      self.rdf_type.include?(self.class.get_deprecated_rdf_type)
    end

    def slug
      self.class.slug_from_uri(self.uri)
    end

    def resource_type
      self.class.name.demodulize.underscore
    end

    def download_prefix
      "#{self.resource_type}_data_#{self.slug.gsub('/', '|')}_#{self.modified.strftime("%Y%m%d")}"
    end

    module ClassMethods

      def sort_by_label_or_uri(array_of_resources)
        # TODO: implement me! :-)
        array_of_resources
      end

      def deprecated_rdf_type(type)
        self._DEPRECATED_RDF_TYPE = type
      end

      def get_deprecated_rdf_type
        self._DEPRECATED_RDF_TYPE
      end

      def uri_from_slug(slug)
        # Implement!
      end

      def slug_from_uri(uri)
        root_uri = self.uri_from_slug('')
        uri.to_s.gsub(root_uri, '')
      end

      def find_by_slug(slug)
        find(uri_from_slug(slug))
      end
    end
  end
end