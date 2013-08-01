module PublishMyData
  module BasicFeatures
    extend ActiveSupport::Concern

    included do
      field :label, RDF::RDFS.label # same as the title
      field :comment, RDF::RDFS.comment #short desc
      field :data_graph_uri, RDF::PMD_DS.graph, is_uri: true
    end

    # Is this resource in the host domain?
    def in_domain?(domain)
      uri.starts_with?("http://" + domain)
    end

    def eager_load!
      eager_load_object_triples!(labels_only: true)
      eager_load_predicate_triples!(labels_only: true)
    end
  end
end