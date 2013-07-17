shared_examples_for PublishMyData::AllFeatures do
  describe '#deprecated?' do
    it 'should be false' do
      resource.deprecated?.should be_false
    end

    context 'when the dataset has been deprecated' do
      before { resource.rdf_type = [resource.rdf_type, resource.class.get_deprecated_rdf_type] }

      it 'should be true' do
        resource.deprecated?.should be_true
      end
    end
  end

  describe '#in_domain?' do
    it 'should return true if the resource URI is in the given domain' do
      host = URI(resource.uri).host
      resource.in_domain?(host).should be_true
    end

    it 'should return false if the resource URI is not in the given domain' do
      resource.in_domain?('http://google.com').should be_false
    end
  end
end