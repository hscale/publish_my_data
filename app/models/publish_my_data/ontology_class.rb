module PublishMyData
  class OntologyClass
    include Tripod::Resource
    include BasicFeatures
    include DefinedByOntology

    rdf_type RDF::OWL.Class
  end
end