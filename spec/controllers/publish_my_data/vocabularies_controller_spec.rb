require 'spec_helper'

module PublishMyData
  describe VocabulariesController do
    it_should_behave_like 'a controller with a dump action' do
      let(:resource) do
        ont = FactoryGirl.create(:external_ontology)
        Vocabulary.find(ont.uri)
      end

      before { Vocabulary.stub(:find_by_data_dump).and_return(resource) }
    end
  end
end