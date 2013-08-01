require 'spec_helper'

describe PublishMyData::ConceptScheme do
  let(:concept_scheme) { FactoryGirl.create(:concept_scheme) }

  it_behaves_like PublishMyData::AllFeatures do
    let(:resource) { concept_scheme }
  end

  it_behaves_like 'an in-house vocabulary' do
    let(:vocabulary) { concept_scheme }
    let(:vocabulary_resource) { concept_scheme.concepts.first }
  end

  describe '#local?' do
    it 'should be true' do
      ontology.local?.should be_true
    end
  end
end