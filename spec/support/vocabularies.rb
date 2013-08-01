shared_examples 'an in-house vocabulary' do
  shared_examples 'contains data from both data and metadata graphs' do
    it 'should contain data about an associated resource in the data graph' do
      dump.should include(vocabulary_resource.uri.to_s)
    end

    it 'should contain data from the metadata graph' do
      dump.should include(vocabulary.label)
    end
  end

  describe '#to_rdf' do
    include_examples 'contains data from both data and metadata graphs' do
      let(:dump) { vocabulary.to_rdf }
    end

    it 'should return valid rdf' do
      RDF::Reader.for(:rdf).new(vocabulary.to_rdf) do |reader|
        reader.readable?.should be_true
      end
    end
  end

  describe '#to_ttl' do
    include_examples 'contains data from both data and metadata graphs' do
      let(:dump) { vocabulary.to_ttl }
    end

    it 'should return valid turtle' do
      RDF::Reader.for(:ttl).new(vocabulary.to_ttl) do |reader|
        reader.readable?.should be_true
      end
    end
  end

  describe '#to_nt' do
    include_examples 'contains data from both data and metadata graphs' do
      let(:dump) { vocabulary.to_nt }
    end

    it 'should return valid n-triples' do
      RDF::Reader.for(:ntriples).new(vocabulary.to_nt) do |reader|
        reader.readable?.should be_true
      end
    end
  end

  describe '#to_json' do
    include_examples 'contains data from both data and metadata graphs' do
      let(:dump) { vocabulary.to_json }
    end

    it 'should return valid json' do
      JSON.parse(vocabulary.to_json).should be_true
    end
  end
end

shared_examples 'an external vocabulary' do
  shared_examples 'contains data from the data graph only' do
    it 'should contain data from the data graph' do
      dump.should include(vocabulary_resource.uri.to_s)
    end

    it 'should not contain data from the metadata graph' do
      dump.should_not include(vocabulary.label)
    end
  end

  describe '#to_rdf' do
    include_examples 'contains data from the data graph only' do
      let(:dump) { vocabulary.to_rdf }
    end

    it 'should return valid rdf' do
      RDF::Reader.for(:rdf).new(vocabulary.to_rdf) do |reader|
        reader.readable?.should be_true
      end
    end
  end

  describe '#to_ttl' do
    include_examples 'contains data from the data graph only' do
      let(:dump) { vocabulary.to_ttl }
    end

    it 'should return valid turtle' do
      RDF::Reader.for(:ttl).new(vocabulary.to_ttl) do |reader|
        reader.readable?.should be_true
      end
    end
  end

  describe '#to_nt' do
    include_examples 'contains data from the data graph only' do
      let(:dump) { vocabulary.to_nt }
    end

    it 'should return valid n-triples' do
      RDF::Reader.for(:ntriples).new(vocabulary.to_nt) do |reader|
        reader.readable?.should be_true
      end
    end
  end

  describe '#to_json' do
    include_examples 'contains data from the data graph only' do
      let(:dump) { vocabulary.to_json }
    end

    it 'should return valid json' do
      JSON.parse(vocabulary.to_json).should be_true
    end
  end

  context 'with metadata triples in the data graph' do
    let!(:data_resource) do
      r = PublishMyData::Ontology.new(vocabulary.uri, vocabulary.data_graph_uri)
      r.title = 'Awesome Title, by Bob'
      r.label = 'Awesome Title, by Bob'
      r.comment = 'Awesome external vocabulary'
      r.description = 'Awesome external vocabulary. Lorem Ipsum etc.'
      r.publisher = 'http://example.com/people#Bob'
      r.license = 'http://example.com/licenses#AwesomeLicence'
      r.contact_email = 'mailto:bob@example.com'
      r.save!
      r
    end

    describe '#label' do
      it 'should come from the metadata graph' do
        vocabulary.label.should == vocabulary.read_attribute(:label)
      end
    end

    describe '#tags' do
      it 'should come from the metadata graph' do
        vocabulary.tags.should == vocabulary.read_attribute(:tags)
      end
    end

    ['comment', 'description', 'publisher', 'license', 'contact_email'].each do |field_name|
      describe "##{field_name}" do
        it 'should come from the data graph' do
          vocabulary.send(field_name).should == data_resource.send(field_name)
        end
      end
    end
  end
end