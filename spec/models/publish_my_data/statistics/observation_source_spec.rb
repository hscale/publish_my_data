require 'spec_helper'

module PublishMyData
  module Statistics
    describe ObservationSource do
      subject(:source) {
        ObservationSource.new(dataset_uri: 'uri:pmd/dataset/1')
      }

      def insert_statements_into_graph(data, graph_uri)
        statements = data.map { |row| RDF::Statement.from(row) }
        data_graph = RDF::Graph.new
        data_graph.insert(*statements)

        Tripod::SparqlClient::Update.update(
          SPARQL::Client::Update.insert_data(data_graph, graph: graph_uri).to_s
        )
      end

      describe "#measure_property_uris" do
        let(:data) {
          [
            [uri('uri:obs/1'),              RDF::CUBE.dataset,              uri('uri:pmd/dataset/1')],
            [uri('uri:pmd/dataset/1'),      RDF::PMD_DS.graph,              uri('uri:pmd/graph/1')],
            [uri('uri:measure-property/a'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],
            [uri('uri:measure-property/b'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],

            [uri('uri:obs/1'),              a,                              uri('http://purl.org/linked-data/cube#Observation')],
            [uri('uri:obs/1'),              uri('uri:measure-property/a'),  "measure value a1"],
            [uri('uri:obs/1'),              uri('uri:measure-property/b'),  "measure value b1"],
            # Another observation which re-uses the measure properties (forces DISTINCT)
            [uri('uri:obs/2'),              a,                              uri('http://purl.org/linked-data/cube#Observation')],
            [uri('uri:obs/2'),              uri('uri:measure-property/a'),  "measure value a2"],
            [uri('uri:obs/2'),              uri('uri:measure-property/b'),  "measure value b2"]
          ]
        }

        let(:other_data) {
          [
            [uri('uri:obs/other1'),         RDF::CUBE.dataset,              uri('uri:pmd/dataset/other')],
            [uri('uri:pmd/dataset/other'),  RDF::PMD_DS.graph,              uri('uri:pmd/graph/2')],
            [uri('uri:measure-property/c'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],
            [uri('uri:measure-property/d'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],

            [uri('uri:obs/other1'),         a,                              uri('http://purl.org/linked-data/cube#Observation')],
            [uri('uri:obs/other1'),         uri('uri:measure-property/c'),  "measure value c1"],
            [uri('uri:obs/other1'),         uri('uri:measure-property/d'),  "measure value d1"],
          ]
        }

        before(:each) do
          insert_statements_into_graph(data,        'uri:pmd/graph/1')
          insert_statements_into_graph(other_data,  'uri:pmd/graph/2')
        end

        it "returns all URIs"do
          pending "we need to use this on a per-dataset basis to construct fragments"
          expect(source.measure_property_uris.sort).to be == %w[
            uri:measure-property/a uri:measure-property/b
          ]
        end
      end

      describe "#observation_value" do
        before(:each) do
          insert_statements_into_graph(data, 'uri:pmd/graph/1')
        end

        context "looking in the right dataset" do
          let(:data) {
            [
              # Observation 1
              [uri('uri:obs/1'), a,                              RDF::CUBE.Observation],
              [uri('uri:obs/1'), RDF::CUBE.dataset,              uri('uri:pmd/data/A')],
              [uri('uri:obs/1'), uri('uri:row-type'),            uri('uri:row/1')],
              [uri('uri:obs/1'), uri('uri:dim/1'),               uri('uri:dim/1/val/1')],
              [uri('uri:obs/1'), uri('uri:measure-property/1'),  1],
              [uri('uri:obs/1'), uri('uri:measure-property/2'),  101],

              # Observation 2
              [uri('uri:obs/2'), a,                              RDF::CUBE.Observation],
              [uri('uri:obs/2'), RDF::CUBE.dataset,              uri('uri:pmd/data/A')],
              [uri('uri:obs/2'), uri('uri:row-type'),            uri('uri:row/2')],
              [uri('uri:obs/2'), uri('uri:dim/1'),               uri('uri:dim/1/val/1')],
              [uri('uri:obs/2'), uri('uri:measure-property/1'),  2],
              [uri('uri:obs/2'), uri('uri:measure-property/2'),  102],
            ]
          }

          example do
            expect(
              source.observation_value(
                dataset_uri:          'uri:pmd/data/A',
                measure_property_uri: 'uri:measure-property/1',
                row_type_uri:         'uri:row-type',
                row_uri:              'uri:row/1',
                cell_coordinates:     { 'uri:dim/1' => 'uri:dim/1/val/1' }
              )
            ).to be == 1
          end
        end

        # This is a separate context because I couldn't make the one above fail with
        # this stray observation no matter how I prepared the data
        context "looking in the wrong dataset" do
          let(:data) {
            [
              [uri('uri:obs/x1'), a,                              RDF::CUBE.Observation],
              [uri('uri:obs/x1'), RDF::CUBE.dataset,              uri('uri:pmd/data/NOT-A')],
              [uri('uri:obs/x1'), uri('uri:row-type'),            uri('uri:row/1')],
              [uri('uri:obs/x1'), uri('uri:dim/1'),               uri('uri:dim/1/val/1')],
              [uri('uri:obs/x1'), uri('uri:measure-property/1'),  666],
              [uri('uri:obs/x1'), uri('uri:measure-property/2'),  667],
            ]
          }

          example do
            expect(
              source.observation_value(
                dataset_uri:          'uri:pmd/data/A',
                measure_property_uri: 'uri:measure-property/1',
                row_type_uri:         'uri:row-type',
                row_uri:              'uri:row/1',
                cell_coordinates:     { 'uri:dim/1' => 'uri:dim/1/val/1' }
              )
            ).to be_nil
          end
        end
      end

      it "limits the rows" do
        pending
      end

      it "allows missing values" do
        pending
      end

      it "chunks the results" do
        pending
      end
    end
  end
end