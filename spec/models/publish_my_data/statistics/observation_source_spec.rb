require 'spec_helper'

module PublishMyData
  module Statistics
    describe ObservationSource do
      subject(:source) {
        ObservationSource.new.tap do |source|
          source.row_uris_detected(
            'http://opendatacommunities.org/def/ontology/geography/refArea',
            ['uri:row/1', 'uri:row/2']
          )
          source.dataset_detected(
            dataset_uri: 'uri:pmd/dataset/1' ,
            measure_property_uri: 'uri:measure-property/1',
            dimensions: {
              'uri:dimension/1' => ['uri:dimension/1/val/1', 'uri:dimension/1/val/2'],
              'uri:dimension/2' => ['uri:dimension/2/val/1', 'uri:dimension/2/val/2']
            }
          )
          source.dataset_detected(
            dataset_uri: 'uri:pmd/dataset/2' ,
            measure_property_uri: 'uri:measure-property/2',
            dimensions: {
              'uri:dimension/3' => ['uri:dimension/3/val/1']
            }
          )
        end
      }

      def insert_statements_into_graph(data, graph_uri)
        statements = data.map { |row| RDF::Statement.from(row) }
        data_graph = RDF::Graph.new
        data_graph.insert(*statements)

        Tripod::SparqlClient::Update.update(
          SPARQL::Client::Update.insert_data(data_graph, graph: graph_uri).to_s
        )
      end

      # Note, this currently uses slightly different data than below, which is confusing.
      # We need to move this anyway.
      describe ".measure_property_uri" do
        let(:data) {
          [
            [uri('uri:obs/1'),              RDF::CUBE.dataSet,              uri('uri:pmd/dataset/1')],
            [uri('uri:pmd/dataset/1'),      RDF::PMD_DS.graph,              uri('uri:pmd/graph/1')],
            [uri('uri:measure-property/a'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],
            [uri('uri:measure-property/b'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],

            [uri('uri:obs/1'),              a,                              uri('http://purl.org/linked-data/cube#Observation')],
            [uri('uri:obs/1'),              uri('uri:measure-property/a'),  "measure value a1"],
            # Another observation which re-uses the measure properties (forces DISTINCT)
            [uri('uri:obs/2'),              a,                              uri('http://purl.org/linked-data/cube#Observation')],
            [uri('uri:obs/2'),              uri('uri:measure-property/a'),  "measure value a2"]
          ]
        }

        let(:other_data) {
          [
            [uri('uri:obs/other1'),         RDF::CUBE.dataSet,              uri('uri:pmd/dataset/other')],
            [uri('uri:pmd/dataset/other'),  RDF::PMD_DS.graph,              uri('uri:pmd/graph/2')],
            [uri('uri:measure-property/c'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],
            [uri('uri:measure-property/d'), a,                              uri('http://purl.org/linked-data/cube#MeasureProperty')],

            [uri('uri:obs/other1'),         a,                              uri('http://purl.org/linked-data/cube#Observation')],
            [uri('uri:obs/other1'),         uri('uri:measure-property/c'),  "measure value c1"],
          ]
        }

        before(:each) do
          insert_statements_into_graph(data,        'uri:pmd/graph/1')
          insert_statements_into_graph(other_data,  'uri:pmd/graph/2')
        end

        example do
          expect(
            ObservationSource.measure_property_uri('uri:pmd/dataset/1')
          ).to be == 'uri:measure-property/a'
        end

        example do
          expect(
            ObservationSource.measure_property_uri('uri:pmd/dataset/other')
          ).to be == 'uri:measure-property/c'
        end
      end

      describe "#observation_value" do
        let(:ref_area) { uri('http://opendatacommunities.org/def/ontology/geography/refArea') }

        before(:each) do
          customise_data
          insert_statements_into_graph(data, 'uri:pmd/graph/1')
        end

        let(:data) {
          [
            # Observation
            [uri('uri:obs/1'), a,                             RDF::CUBE.Observation],
            [uri('uri:obs/1'), RDF::CUBE.dataSet,             uri('uri:pmd/dataset/1')],
            [uri('uri:obs/1'), ref_area,                      uri('uri:row/1')],
            [uri('uri:obs/1'), uri('uri:dimension/1'),        uri('uri:dimension/1/val/1')],
            [uri('uri:obs/1'), uri('uri:dimension/2'),        uri('uri:dimension/2/val/1')],
            [uri('uri:obs/1'), uri('uri:measure-property/1'), 1],
            [uri('uri:obs/1'), uri('uri:measure-property/2'), 101],

            # Observation
            [uri('uri:obs/2'), a,                             RDF::CUBE.Observation],
            [uri('uri:obs/2'), RDF::CUBE.dataSet,             uri('uri:pmd/dataset/1')],
            [uri('uri:obs/2'), ref_area,                      uri('uri:row/1')],
            [uri('uri:obs/2'), uri('uri:dimension/1'),        uri('uri:dimension/1/val/1')],
            [uri('uri:obs/2'), uri('uri:dimension/2'),        uri('uri:dimension/2/val/2')],
            [uri('uri:obs/2'), uri('uri:measure-property/1'), 2],
            [uri('uri:obs/2'), uri('uri:measure-property/2'), 102],

            # Observation
            [uri('uri:obs/3'), a,                             RDF::CUBE.Observation],
            [uri('uri:obs/3'), RDF::CUBE.dataSet,             uri('uri:pmd/dataset/1')],
            [uri('uri:obs/3'), ref_area,                      uri('uri:row/1')],
            [uri('uri:obs/3'), uri('uri:dimension/1'),        uri('uri:dimension/1/val/2')],
            [uri('uri:obs/3'), uri('uri:dimension/2'),        uri('uri:dimension/2/val/1')],
            [uri('uri:obs/3'), uri('uri:measure-property/1'), 3],
            [uri('uri:obs/3'), uri('uri:measure-property/2'), 103],

            # Observation
            [uri('uri:obs/4'), a,                             RDF::CUBE.Observation],
            [uri('uri:obs/4'), RDF::CUBE.dataSet,             uri('uri:pmd/dataset/1')],
            [uri('uri:obs/4'), ref_area,                      uri('uri:row/1')],
            [uri('uri:obs/4'), uri('uri:dimension/1'),        uri('uri:dimension/1/val/2')],
            [uri('uri:obs/4'), uri('uri:dimension/2'),        uri('uri:dimension/2/val/2')],
            [uri('uri:obs/4'), uri('uri:measure-property/1'), 4],
            [uri('uri:obs/4'), uri('uri:measure-property/2'), 104],

            # Observation (dataset 2, row 2)
            [uri('uri:obs/5'), a,                             RDF::CUBE.Observation],
            [uri('uri:obs/5'), RDF::CUBE.dataSet,             uri('uri:pmd/dataset/2')],
            [uri('uri:obs/5'), ref_area,                      uri('uri:row/2')],
            [uri('uri:obs/5'), uri('uri:dimension/3'),        uri('uri:dimension/3/val/1')],
            [uri('uri:obs/5'), uri('uri:measure-property/1'), 105],
            [uri('uri:obs/5'), uri('uri:measure-property/2'), 5],
          ]
        }

        context "all the data" do
          def customise_data
            # Nothing to do in this context
          end

          example "dataset 1, row 1, dimension 1 val 1, dimension 2 val 1" do
            expect(
              source.observation_value(
                dataset_uri:          'uri:pmd/dataset/1',
                measure_property_uri: 'uri:measure-property/1',
                row_uri:              'uri:row/1',
                cell_coordinates:     {
                  'uri:dimension/1' => 'uri:dimension/1/val/1',
                  'uri:dimension/2' => 'uri:dimension/2/val/1'
                }
              )
            ).to be == 1
          end

          example "dataset 1, row 1, dimension 2 val 1, dimension 2 val 2" do
            expect(
              source.observation_value(
                dataset_uri:          'uri:pmd/dataset/1',
                measure_property_uri: 'uri:measure-property/1',
                row_uri:              'uri:row/1',
                cell_coordinates:     {
                  'uri:dimension/1' => 'uri:dimension/1/val/2',
                  'uri:dimension/2' => 'uri:dimension/2/val/2'
                }
              )
            ).to be == 4
          end

          example "dataset 2, row 2, dimension 3 val 1" do
            expect(
              source.observation_value(
                dataset_uri:          'uri:pmd/dataset/1',
                measure_property_uri: 'uri:measure-property/2',
                row_uri:              'uri:row/2',
                cell_coordinates:     {
                  'uri:dimension/3' => 'uri:dimension/3/val/1'
                }
              )
            ).to be == 5
          end
        end

        context "with a missing value" do
          def customise_data
            data.delete([uri('uri:obs/1'), ref_area, uri('uri:row/1')])
          end

          it "returns nil" do
            expect(
              source.observation_value(
                dataset_uri:          'uri:pmd/dataset/1',
                measure_property_uri: 'uri:measure-property/1',
                row_uri:              'uri:row/1',
                cell_coordinates:     {
                  'uri:dimension/1' => 'uri:dimension/1/val/1',
                  'uri:dimension/2' => 'uri:dimension/2/val/1'
                }
              )
            ).to be_nil
          end

          it "doesn't affect other values in the same row (like in the grid viewer)" do
            expect(
              source.observation_value(
                dataset_uri:          'uri:pmd/dataset/1',
                measure_property_uri: 'uri:measure-property/1',
                row_uri:              'uri:row/1',
                cell_coordinates:     {
                  'uri:dimension/1' => 'uri:dimension/1/val/1',
                  'uri:dimension/2' => 'uri:dimension/2/val/2'
                }
              )
            ).to be == 2
          end
        end
      end

      it "has a Labeller" do
        pending
      end

      it "uses a graph block" do
        pending
      end

      it "limits the rows" do
        pending
      end

      it "chunks the results" do
        pending
      end
    end
  end
end