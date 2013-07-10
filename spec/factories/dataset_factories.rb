FactoryGirl.define do
  factory :my_dataset, class: PublishMyData::Dataset do
    initialize_with { new(uri, graph_uri) }
    title 'My Dataset'
    description 'A test dataset'
    modified DateTime.parse('2010-07-01 12:00')
    data_graph_uri PublishMyData::Dataset.data_graph_uri("my/dataset")
    ignore do
      uri { PublishMyData::Dataset.uri_from_slug("my/dataset")  }
      graph_uri { PublishMyData::Dataset.metadata_graph_uri("my/dataset") }
    end
  end

  factory :another_dataset, class: PublishMyData::Dataset do
    initialize_with { new(uri, graph_uri) }
    title 'My Other Dataset'
    description 'Another test dataset'
    modified DateTime.parse('2010-07-01 12:00')
    data_graph_uri PublishMyData::Dataset.data_graph_uri("my/other-dataset")
    ignore do
      uri { PublishMyData::Dataset.uri_from_slug("my/other-dataset")  }
      graph_uri { PublishMyData::Dataset.metadata_graph_uri("my/other-dataset") }
    end
  end
end
