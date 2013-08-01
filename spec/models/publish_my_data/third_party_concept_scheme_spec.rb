require 'spec_helper'

describe PublishMyData::ThirdParty::ConceptScheme do
  let(:concept_scheme) { FactoryGirl.create(:external_concept_scheme) }

  it_behaves_like 'an external vocabulary' do
    let(:vocabulary) { concept_scheme }
    let(:vocabulary_resource) { concept_scheme.concepts.first }
  end

  describe '#local?' do
    it 'should be false' do
      ontology.local?.should be_false
    end
  end
end