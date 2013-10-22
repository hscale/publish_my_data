FactoryGirl.define do
  factory :dataset, aliases: [:my_dataset], class: PublishMyData::Dataset do
    initialize_with { new(uri, graph_uri) }
    title 'My Dataset'
    description 'A test dataset'
    modified DateTime.parse('2010-07-01 12:00')
    ignore do
      slug "my/dataset"
    end
    data_graph_uri { PublishMyData::Dataset.data_graph_uri(slug) }
    ignore do
      uri { PublishMyData::Dataset.uri_from_slug(slug)  }
      graph_uri { PublishMyData::Dataset.metadata_graph_uri(slug) }
    end

    factory :data_cube do
      after(:build) do |dataset|
        r = FactoryGirl.build(:observation)
        r.write_predicate(RDF::CUBE.dataSet, dataset.uri)
        r.save!
      end
    end
  end

  factory :geo_data_cube, class: PublishMyData::Dataset do
    initialize_with { new(uri, graph_uri) }
    title 'My Geo-dataset'
    description 'A test dataset containing geographical data'
    modified DateTime.parse('2010-07-01 12:00')
    data_graph_uri PublishMyData::Dataset.data_graph_uri("my/geo/dataset")
    ignore do
      uri { PublishMyData::Dataset.uri_from_slug("my/geo/dataset")  }
      graph_uri { PublishMyData::Dataset.metadata_graph_uri("my/geo/dataset") }
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
