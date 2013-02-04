FactoryGirl.define do
  factory :unicorn_resource, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://pmdtest.dev/id/unicorns/yuri" }
      graph_uri { "http://pmdtest.dev/graph/unicorns" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Yuri The Unicorn')
    end
  end

end