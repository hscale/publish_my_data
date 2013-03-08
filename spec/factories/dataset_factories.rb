FactoryGirl.define do
  factory :my_dataset, class: PublishMyData::Dataset do
    initialize_with { new(uri, graph_uri) }
    title 'My Dataset'
    description 'A test dataset'
    ignore do
      uri { PublishMyData::Dataset.uri_from_slug("my-dataset")  }
      graph_uri { PublishMyData::Dataset.metadata_graph_uri("my-dataset") }
    end
  end

  factory :another_dataset, class: PublishMyData::Dataset do
    initialize_with { new(uri, graph_uri) }
    title 'My Other Dataset'
    description 'Another test dataset'
    ignore do
      uri { PublishMyData::Dataset.uri_from_slug("another-dataset")  }
      graph_uri { PublishMyData::Dataset.metadata_graph_uri("another-dataset") }
    end
  end
end
