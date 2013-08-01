FactoryGirl.define do
  factory :concept_scheme, class: PublishMyData::ConceptScheme do
    initialize_with { new(uri,graph_uri) }
    label 'My Awesome Concept Scheme'
    modified DateTime.parse('2010-07-01 12:00')
    data_graph_uri "http://#{PublishMyData.local_domain}/graph/my-topic"
    ignore do
      uri { PublishMyData::ConceptScheme.uri_from_slug("my-topic") }
      graph_uri {  "http://#{PublishMyData.local_domain}/graph/my-topic/metadata" }
    end
    after(:create) do |cs, evaluator|
      # set up some concepts
      c = PublishMyData::Concept.new("http://#{PublishMyData.local_domain}/def/my-topic/concept/my-concept", evaluator.data_graph_uri )
      c.label = "A concept"
      c.in_scheme = cs.uri
      c.save!

      c2 = PublishMyData::Concept.new("http://#{PublishMyData.local_domain}/def/my-topic/concept/my-concept-2", evaluator.data_graph_uri )
      c2.label = "Another concept"
      c2.in_scheme = cs.uri
      c2.save!

      cs.save!
    end
  end

  factory :external_concept_scheme, class: PublishMyData::ThirdParty::ConceptScheme do
    initialize_with { new(uri,graph_uri) }
    label 'My External Concept Scheme'
    tags ['foo', 'bar', 'baz']
    data_graph_uri "http://#{PublishMyData.local_domain}/123456abcdef123456"
    ignore do
      uri { "http://example.com/def/my-topic/concept-scheme/my-concept-scheme"}
      graph_uri { "http://#{PublishMyData.local_domain}/123456abcdef123456/metadata" }
    end
    after(:create) do |cs, evaluator|
      # set up some concepts
      c = PublishMyData::Concept.new("http://example.com/def/my-topic/concept/my-concept", evaluator.data_graph_uri )
      c.label = "A concept"
      c.in_scheme = cs.uri
      c.save!

      c2 = PublishMyData::Concept.new("http://example.com/def/my-topic/concept/my-concept-2", evaluator.data_graph_uri )
      c2.label = "Another concept"
      c2.in_scheme = cs.uri
      c2.save!

      cs.save!
    end
  end

end