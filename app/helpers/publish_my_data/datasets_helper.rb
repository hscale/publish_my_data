module PublishMyData
  module DatasetsHelper
    def formatted_date(date_string)
      unless date_string.blank?
        DateTime.parse(date_string).to_s(:long)
      else 
        date_string
      end
    end

    def vocabulary_class(dataset, uri)
      dataset.ontologies.each_with_index do |ontology, index|
        uris = ontology.classes.map(&:uri) + ontology.properties.map(&:uri)
        return "ontology_#{index}" if uris.any?{|u| uri == u}
      end
      dataset.concept_schemes.each_with_index do |concept_scheme, index|
        uris = concept_scheme.concepts.map(&:uri)
        return "concept_scheme_#{index}" if uris.any?{|u| uri == u}
      end
      return ''
    end

    def example_resource_for_type(dataset, type)
      dataset.example_resources.detect {|r| r.rdf_type.include?(type.uri) }
    end

    def types_for_example_resource(dataset, example_resource)
      dataset.types.select {|t| example_resource.rdf_type.include?(t.uri) }
    end
  end
end