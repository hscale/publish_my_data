module PublishMyData
  class OntologyClass
    include Tripod::Resource
    include PublishMyData::Concerns::Models::Resource
    include PublishMyData::DefinedByOntology

    field :label, RDF::RDFS.label
    field :defined_by, RDF::RDFS.isDefinedBy

  end
end