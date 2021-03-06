FactoryGirl.define do
  factory :mean_result, class: PublishMyData::Property do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/def/statistics/meanResult" }
      graph_uri { "http://#{PublishMyData.local_domain}/ontology/statistics" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Mean Result')
    end
  end

end