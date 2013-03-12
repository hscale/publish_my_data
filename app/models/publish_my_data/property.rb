module PublishMyData
  class Property
    include Tripod::Resource
    include PublishMyData::ResourceModule
    include PublishMyData::DefinedByOntology

    field :label, RDF::RDFS.label
    field :defined_by, RDF::RDFS.isDefinedBy

  end
end