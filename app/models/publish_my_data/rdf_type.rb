module PublishMyData
  class RdfType
    include Tripod::Resource
    field :label, RDF::RDFS.label
    field :comment, RDF::RDFS.comment
  end
end
