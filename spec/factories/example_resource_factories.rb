FactoryGirl.define do
  factory :example_resource, class: PublishMyData::ExampleResource do
    initialize_with { new(uri, graph_uri) }
    ignore do
      uri { "http://#{PublishMyData.local_domain}/data/trousers/measurement1" }
      graph_uri { "http://#{PublishMyData.local_domain}/graph/trousers" }
    end
  end
end