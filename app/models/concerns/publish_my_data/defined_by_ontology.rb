module PublishMyData
  module DefinedByOntology
    extend ActiveSupport::Concern

    included do
      field :defined_by, RDF::RDFS.isDefinedBy, :is_uri => true
    end

    def defined_by_ontology
      ontology_uri = read_predicate(RDF::RDFS.isDefinedBy).first
      Ontology.find(ontology_uri) rescue nil if ontology_uri
    end

  end
end