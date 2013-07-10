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
  end
end