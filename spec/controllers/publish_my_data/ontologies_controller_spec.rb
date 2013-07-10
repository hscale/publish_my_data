require 'spec_helper'

module PublishMyData
  describe OntologiesController do
    it_should_behave_like 'a controller with a dump action' do
      let(:resource) { FactoryGirl.create(:ontology) }
    end
  end
end