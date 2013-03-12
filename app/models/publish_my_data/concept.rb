module PublishMyData
  class Concept
    include Tripod::Resource
    include PublishMyData::ResourceModule
    field :label, RDF::RDFS.label
    field :in_scheme, RDF::SKOS.inScheme

    rdf_type RDF::SKOS.Concept

    def concept_scheme
      ConceptScheme.find(self.in_scheme) rescue nil if self.in_scheme
    end
  end
end