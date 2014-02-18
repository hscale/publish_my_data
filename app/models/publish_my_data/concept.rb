module PublishMyData
  class Concept
    include Tripod::Resource
    include BasicFeatures

    field :in_scheme, RDF::SKOS.inScheme, :is_uri => true

    rdf_type RDF::SKOS.Concept

    def concept_scheme
      ConceptScheme.find(self.in_scheme) rescue nil if self.in_scheme
    end
  end
end