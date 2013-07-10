FactoryGirl.define do
  factory :concept_scheme, class: PublishMyData::ConceptScheme do
    initialize_with { new(uri,graph_uri) }
    label 'My Concept Scheme'
    modified DateTime.parse('2010-07-01 12:00')
    ignore do
      uri { PublishMyData::ConceptScheme.uri_from_slug("my-topic") }
      graph_uri {  "http://#{PublishMyData.local_domain}/def/concept-scheme/my-topic/metadata" }
    end
    after(:create) do |cs, evaluator|
      # set up some concepts
      c = PublishMyData::Concept.new("http://#{PublishMyData.local_domain}/def/my-topic/concept/my-concept", evaluator.graph_uri )
      c.label = "my concept"
      c.in_scheme = cs.uri
      c.save!

      c2 = PublishMyData::Concept.new("http://#{PublishMyData.local_domain}/def/my-topic/concept/my-concept-2", evaluator.graph_uri )
      c2.label = "my other concept"
      c2.in_scheme = cs.uri
      c2.save!

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
      c = PublishMyData::Concept.new("http://example.com/def/my-topic/concept/my-concept", evaluator.graph_uri )
      c.label = "my concept"
      c.in_scheme = cs.uri
      c.save!

      c2 = PublishMyData::Concept.new("http://example.com/def/my-topic/concept/my-concept-2", evaluator.graph_uri )
      c2.label = "my other concept"
      c2.in_scheme = cs.uri
      c2.save!

      cs.save!
    end
  end

end