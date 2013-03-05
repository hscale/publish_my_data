module PublishMyData
  class Ontology
    include Tripod::Resource
    include PublishMyData::ResourceModule

    rdf_type RDF::OWL.Ontology
  end
end
