require 'spec_helper'

describe PublishMyData::ExampleResource do
  let(:example_resource) { FactoryGirl.create(:example_resource) }

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