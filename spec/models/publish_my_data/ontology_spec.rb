require 'spec_helper'

describe PublishMyData::Ontology do
  it_behaves_like PublishMyData::AllFeatures do
    let(:resource) { FactoryGirl.build(:ontology) }
  end
end