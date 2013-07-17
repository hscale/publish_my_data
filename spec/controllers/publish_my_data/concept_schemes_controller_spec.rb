require 'spec_helper'

module PublishMyData
  describe ConceptSchemesController do
    it_should_behave_like 'a controller with a dump action' do
      let(:resource) { FactoryGirl.create(:concept_scheme) }
    end
  end
end