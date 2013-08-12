module PublishMyData
  class Property
    include Tripod::Resource
    include BasicFeatures
    include DefinedByOntology

    rdf_type RDF.Property
  end
end