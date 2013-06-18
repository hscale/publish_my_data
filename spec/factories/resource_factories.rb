FactoryGirl.define do
  factory :yuri_unicorn_resource, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/id/unicorns/yuri" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/unicorns" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Yuri The Unicorn')
    end
  end

  factory :boris_unicorn_resource, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/id/unicorns/boris" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/unicorns" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Boris The Unicorn')
      res.write_predicate('http://example.com/knows', RDF::URI("http://pmdtest.dev/id/unicorns/yuri")) # knows yuri
      res.write_predicate('http://example.com/resides-in', RDF::URI("http://locations.example.com/foo")) # resides in foo county
    end
  end

  factory :foreign_resource, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://locations.example.com/foo" }
      graph_uri { "http://#{PublishMyData.local_domain}/geo" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Foo County')
    end
  end

  factory :information_resource, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/data/information/resource" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/info" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Info Res')
    end
  end

end