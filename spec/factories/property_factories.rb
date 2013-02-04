FactoryGirl.define do
  factory :mean_result, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://pmdtest.dev/def/statistics/meanResult" }
      graph_uri { "http://pmdtest.dev/ontology/statistics" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Mean Result')
    end
  end

end