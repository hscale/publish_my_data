module PublishMyData
  class RdfType
    include Tripod::Resource
    field :label, RDF::RDFS.label
  end
end
