module PublishMyData
  class ConceptScheme
    include Tripod::Resource
    include PublishMyData::ResourceModule #some common methods for resources.

    rdf_type RDF::SKOS.ConceptScheme
  end
end
