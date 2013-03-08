FactoryGirl.define do
  factory :concept_scheme, class: PublishMyData::ConceptScheme do
    initialize_with { new(uri,graph_uri) }
    label 'My Concept Scheme'
    ignore do
      uri { "http://#{PublishMyData.local_domain}/def/my-topic/concept-scheme/my-concept-scheme"}
      graph_uri {  "http://#{PublishMyData.local_domain}/def/my-topic/concept-scheme/graph" }
    end
    after(:create) do |cs, evaluator|
      # set up some concepts
      c = PublishMyData::Resource.new("http://#{PublishMyData.local_domain}/def/my-topic/concept/my-concept", evaluator.graph_uri )
      c.label = "my concept"
      c.save!

      c2 = PublishMyData::Resource.new("http://#{PublishMyData.local_domain}/def/my-topic/concept/my-concept-2", evaluator.graph_uri )
      c2.label = "my other concept"
      c2.save!

      cs.write_predicate(RDF::SKOS.hasTopConcept, [c.uri, c2.uri])
      cs.save!
    end
  end

  factory :external_concept_scheme, class: PublishMyData::ConceptScheme do
    initialize_with { new(uri,graph_uri) }
    label 'My External Concept Scheme'
    ignore do
      uri { "http://example.com/def/my-topic/concept-scheme/my-concept-scheme"}
      graph_uri {  "http://#{PublishMyData.local_domain}/def/example-com-my-topic/concept-scheme/graph" }
    end
    after(:create) do |cs, evaluator|
      # set up some concepts
      c = PublishMyData::Resource.new("http://example.com/def/my-topic/concept/my-concept", evaluator.graph_uri )
      c.label = "my concept"
      c.save!

      c2 = PublishMyData::Resource.new("http://example.com/def/my-topic/concept/my-concept-2", evaluator.graph_uri )
      c2.label = "my other concept"
      c2.save!

      cs.write_predicate(RDF::SKOS.hasTopConcept, [c.uri, c2.uri])
      cs.save!
    end
  end

end