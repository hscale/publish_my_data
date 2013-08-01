require 'spec_helper'

describe PublishMyData::ThirdParty::Ontology do
  let(:ontology) { FactoryGirl.create(:external_ontology) }

  it_behaves_like 'an external vocabulary' do
    let(:vocabulary) { ontology }
    let(:vocabulary_resource) { ontology.classes.first }
  end

  describe '#local?' do
    it 'should be false' do
      ontology.local?.should be_false
    end
  end
end