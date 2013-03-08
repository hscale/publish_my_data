FactoryGirl.define do

  factory :ontology, class: PublishMyData::Ontology do
    initialize_with { new(uri,graph_uri) }
    label 'My Ontology'
    ignore do
      uri { "http://#{PublishMyData.local_domain}/def/my-topic/ontology"}
      graph_uri {  "http://#{PublishMyData.local_domain}/def/my-topic/ontology/graph" }
    end
    after(:create) do |o, evaluator|
      # set up some classes and props
      c = PublishMyData::Resource.new("http://#{PublishMyData.local_domain}/def/my-topic/my-class", evaluator.graph_uri )
      c.write_predicate(RDF::RDFS.isDefinedBy, o.uri)
      c.write_predicate(RDF.type, RDF::OWL.Class)
      c.save!

      c2 = PublishMyData::Resource.new("http://#{PublishMyData.local_domain}/def/my-topic/my-class-2", evaluator.graph_uri )
      c2.write_predicate(RDF::RDFS.isDefinedBy, o.uri)
      c2.write_predicate(RDF.type, RDF::OWL.Class)
      c2.save!

      p = PublishMyData::Resource.new("http://#{PublishMyData.local_domain}/def/my-topic/my-property", evaluator.graph_uri)
      p.write_predicate(RDF::RDFS.isDefinedBy, o.uri)
      p.write_predicate(RDF.type, RDF.Property)
      p.save!

      p2 = PublishMyData::Resource.new("http://#{PublishMyData.local_domain}/def/my-topic/my-property-2", evaluator.graph_uri )
      p2.write_predicate(RDF::RDFS.isDefinedBy, o.uri)
      p2.write_predicate(RDF.type, RDF.Property)
      p2.save!
    end
  end

end