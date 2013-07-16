FactoryGirl.define do

  factory :ontology, class: PublishMyData::Ontology do
    initialize_with { new(uri,graph_uri) }
    label 'My Ontology'
    modified DateTime.parse('2010-07-01 12:00')
    ignore do
      uri { PublishMyData::Ontology.uri_from_slug("my-topic") }
      graph_uri {  "http://#{PublishMyData.local_domain}/def/my-topic/metadata" }
    end
    after(:create) do |o, evaluator|
      # set up some classes and props
      c = PublishMyData::OntologyClass.new("http://#{PublishMyData.local_domain}/def/my-topic/my-class", evaluator.graph_uri )
      c.defined_by = o.uri
      c.write_predicate(RDF.type, RDF::OWL.Class)
      c.save!

      c2 = PublishMyData::OntologyClass.new("http://#{PublishMyData.local_domain}/def/my-topic/my-class-2", evaluator.graph_uri )
      c2.defined_by = o.uri
      c2.write_predicate(RDF.type, RDF::OWL.Class)
      c2.save!

      p = PublishMyData::Property.new("http://#{PublishMyData.local_domain}/def/my-topic/my-property", evaluator.graph_uri)
      p.defined_by = o.uri
      p.write_predicate(RDF.type, RDF.Property)
      p.save!

      p2 = PublishMyData::Property.new("http://#{PublishMyData.local_domain}/def/my-topic/my-property-2", evaluator.graph_uri )
      p2.defined_by = o.uri
      p2.write_predicate(RDF.type, RDF.Property)
      p2.save!
    end
  end

  factory :external_ontology, class: PublishMyData::Ontology do
    initialize_with { new(uri,graph_uri) }
    label 'My External Ontology'
    modified DateTime.parse('2010-07-01 12:00')
    ignore do
      uri { "http://example.com/def/ontology/my-topic/"}
      graph_uri {  "http://#{PublishMyData.local_domain}/def/example-com-my-topic/ontology/graph" }
    end
    after(:create) do |o, evaluator|
      # set up some classes and props
      c = PublishMyData::OntologyClass.new("http://example.com/def/my-topic/my-class", evaluator.graph_uri )
      c.defined_by = o.uri
      c.write_predicate(RDF.type, RDF::OWL.Class)
      c.save!

      p = PublishMyData::Property.new("http://example.com/def/my-topic/my-property", evaluator.graph_uri)
      p.defined_by = o.uri
      p.write_predicate(RDF.type, RDF.Property)
      p.save!
    end
  end

end