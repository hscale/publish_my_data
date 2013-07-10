module PublishMyData
  class OntologyClass
    include Tripod::Resource
    include BasicFeatures
    include DefinedByOntology
  end
end