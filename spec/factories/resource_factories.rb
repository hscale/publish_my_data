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

  factory :geographical_resource, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/data/geographical/resource" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/geography" }
    end
    after(:build) do |res|
      res.rdf_type = RDF::URI("http://statistics.data.gov.uk/def/statistical-geography")
    end
  end

  factory :observation, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/data/resources/1" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/data_cube" }
    end
    after(:build) do |res|
      res.rdf_type = RDF::CUBE.Observation
    end
  end

  factory :geo_observation, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/data/resources/geo/1" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/geo_data_cube" }
    end

    after(:build) do |res|
      res.rdf_type = RDF::CUBE.Observation
      ref_area = FactoryGirl.create(:geographical_resource)
      res.write_predicate("http://opendatacommunities.org/def/ontology/geography/refArea", ref_area.uri)
    end
  end

  factory :rdf_type, class: PublishMyData::Resource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/id/types/observation" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/types" }
    end
    after(:build) do |res|
      res.write_predicate(RDF::RDFS.label, 'Observation')
    end
  end
end