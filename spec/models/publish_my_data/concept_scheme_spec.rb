require 'spec_helper'

describe PublishMyData::ConceptScheme do
  it_behaves_like PublishMyData::AllFeatures do
    let(:resource) { FactoryGirl.build(:concept_scheme) }
  end
end