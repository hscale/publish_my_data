require 'spec_helper'

feature 'Viewing resources' do
  context 'Given a dataset' do
    given(:dataset) { FactoryGirl.create(:my_dataset) }

    scenario 'Visitor dereferences the URI' do
      visit dataset.uri
      page.should have_content dataset.title
    end
  end

  context 'Given an in-house ontology' do
    given(:ontology) { FactoryGirl.create(:ontology) }

    scenario 'Visitor dereferences the URI' do
      visit ontology.uri
      page.should have_content ontology.title
      page.should have_content('Classes')
      page.should have_content ontology.classes.first.label
      page.should have_content('Properties')
      page.should have_content ontology.properties.first.label
    end
  end

  context 'Given an in-house concept scheme' do
    given(:concept_scheme) { FactoryGirl.create(:concept_scheme) }

    scenario 'Visitor dereferences the URI' do
      visit concept_scheme.uri
      page.should have_content concept_scheme.title
      page.should have_content('Concepts')
      page.should have_content(concept_scheme.concepts.first.label)
    end
  end

  context 'Given a concept' do
    given(:concept_scheme) { FactoryGirl.create(:concept_scheme) }
    given(:concept) { concept_scheme.concepts.first }

    scenario 'Visitor dereferences the URI' do
      visit concept.uri
      page.should have_content concept.uri
      page.should have_content RDF::SKOS.inScheme
      page.should have_content concept_scheme.uri
    end
  end

  context 'Given an ontology class' do
    given(:ontology) { FactoryGirl.create(:ontology) }
    given(:ontology_class) { ontology.classes.first }

    scenario 'Visitor dereferences the URI' do
      visit ontology_class.uri
      page.should have_content ontology_class.uri
      page.should have_content RDF::RDFS.isDefinedBy
      page.should have_content ontology.uri
    end
  end

  context 'Given a property' do
    given(:ontology) { FactoryGirl.create(:ontology) }
    given(:ontology_property) { ontology.properties.first }

    scenario 'Visitor dereferences the URI' do
      visit ontology_property.uri
      page.should have_content ontology_property.uri
      page.should have_content RDF::RDFS.isDefinedBy
      page.should have_content ontology.uri
    end
  end

  context 'Given an external ontology' do
    given(:ontology) { FactoryGirl.create(:external_ontology) }

    scenario 'Visitor visits the resource page' do
      visit "/resource?uri=#{ontology.uri}"
      page.should have_content ontology.title
      page.should have_content('Classes')
      page.should have_content ontology.classes.first.label
      page.should have_content('Properties')
      page.should have_content ontology.properties.first.label
    end
  end

  context 'Given an external concept scheme' do
    given(:concept_scheme) { FactoryGirl.create(:external_concept_scheme) }

    scenario 'Visitor visits the resource page' do
      visit "/resource?uri=#{concept_scheme.uri}"
      page.should have_content concept_scheme.title
      page.should have_content('Concepts')
      page.should have_content(concept_scheme.concepts.first.label)
    end
  end
end