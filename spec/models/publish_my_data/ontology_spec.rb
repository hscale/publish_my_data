require 'spec_helper'

describe PublishMyData::Ontology do
  let(:ontology) { FactoryGirl.create(:ontology) }

  it_behaves_like PublishMyData::AllFeatures do
    let(:resource) { ontology }
  end

  it_behaves_like 'an in-house vocabulary' do
    let(:vocabulary) { ontology }
    let(:vocabulary_resource) { ontology.classes.first }
  end

  describe '#local?' do
    it 'should be true' do
      ontology.local?.should be_true
    end
  end
end