module PublishMyData
  class Property
    include Tripod::Resource
    include BasicFeatures
    include DefinedByOntology
  end
end