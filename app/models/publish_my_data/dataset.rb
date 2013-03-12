module PublishMyData
  class Dataset
    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    field :title, RDF::DC.title
    field :comment, RDF::RDFS.comment #short desc
    field :description, RDF::DC.description # long desc

    field :theme, SITE_VOCAB.theme
    field :tags, 'http://www.w3.org/ns/dcat#keyword', :mutlivalued => true
    field :modified, RDF::DC.modified
    field :created, RDF::DC.created

    field :owner, RDF::DC.publisher
    field :license, RDF::DC.license
    field :contact, RDF::FOAF.mbox

    rdf_type PMD_DS_VOCAB.Dataset

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
