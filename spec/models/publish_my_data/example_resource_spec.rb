require 'spec_helper'

describe PublishMyData::ExampleResource do
  let(:example_resource) { FactoryGirl.create(:example_resource) }

  describe '#rdf_type_as_resource' do
    context 'given an rdf_type which has associated triples in the database' do
      let(:rdf_type) { FactoryGirl.create(:rdf_type) }
      before do
        example_resource.rdf_type = rdf_type.uri
        example_resource.save!
        example_resource.eager_load!
      end

      it 'should return the rdf type as a Resource' do
        example_resource.rdf_type_as_resource.should == rdf_type
      end
    end

    context 'where there are no additional triples for the rdf type' do
      it 'should return nil' do
        example_resource.rdf_type_as_resource.should == nil
      end
    end
  end

  describe '#as_ttl' do
    before do
      example_resource.write_predicate('http://example.com/foo', 'foo')
      example_resource.write_predicate('http://example.com/bar', 'bar')
    end
    it 'should return the turtle representation of the example resource' do
      example_resource.as_ttl.should == """
<http://pmdtest.dev/data/trousers/measurement1> <http://example.com/bar> \"bar\";
   <http://example.com/foo> \"foo\" .
"""
    end
  end
end