require 'spec_helper'

module PublishMyData
  module Statistics
    describe Labeller do
      subject(:labeller) { Labeller.new }

      before(:each) do
        Tripod::SparqlClient::Update.update <<-SPARQL
          PREFIX eg: <http://example.com/>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

          INSERT DATA {
            eg:resource-1 rdfs:label          "Resource 1"@en .
            eg:resource-2 rdfs:label          "Resource 2"@en .
            eg:resource-3 rdfs:label          "Resource 3"@en .
            eg:resource-4 eg:other-property   "Resource 4 has no label" .
            eg:resource-5 eg:other-property   "Resource 5 has no label"
          }
        SPARQL
      end

      before(:each) do
        labeller.resource_detected('http://example.com/resource-1')
        labeller.resource_detected('http://example.com/resource-2')
        labeller.resource_detected('http://example.com/resource-4')
      end

      it "labels detected resources" do
        expect(
          labeller.label_for('http://example.com/resource-1')
        ).to be == "Resource 1"
        expect(
          labeller.label_for('http://example.com/resource-2')
        ).to be == "Resource 2"
      end

      # We could make it fetch them separately, but that exposes us to
      # silently making thousands of queries if we miss a large set
      # of data we want labelling
      it "returns the URI for undetected resources" do
        expect(
          labeller.label_for('http://example.com/resource-3')
        ).to be == 'http://example.com/resource-3'
      end

      it "returns the URI for detected but unlabelled resources" do
        expect(
          labeller.label_for('http://example.com/resource-4')
        ).to be == 'http://example.com/resource-4'
      end

      # Actually the same as merely undetected resources
      it "returns the URI for undetected, unlabelled resources" do
        expect(
          labeller.label_for('http://example.com/resource-5')
        ).to be == 'http://example.com/resource-5'
      end
    end
  end
end