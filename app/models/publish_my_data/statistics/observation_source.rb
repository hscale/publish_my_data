require 'sparql/client'

module PublishMyData
  module Statistics
    class ObservationSource
      REF_AREA = 'http://opendatacommunities.org/def/ontology/geography/refArea'

      class << self
        def measure_property_uri(dataset_uri)
          results = Tripod::SparqlClient::Query.select <<-SPARQL
            PREFIX qb: <http://purl.org/linked-data/cube#>

            SELECT DISTINCT ?measureProperty WHERE {
              ?measureProperty a qb:MeasureProperty .
              <#{dataset_uri}> <#{RDF::PMD_DS.graph}> ?datasetGraph .
              GRAPH ?datasetGraph {
                ?obs ?measureProperty ?value .
              }
            }
          SPARQL

          results.first['measureProperty']['value']
        end
      end

      def initialize(query_options)
        @dimension_values = query_options.fetch(:dimensions)
      end

      def observation_value(description)
        # Bring on Ruby 2 and kwargs...
        dataset_uri           = description.fetch(:dataset_uri)
        measure_property_uri  = description.fetch(:measure_property_uri)
        row_uri               = description.fetch(:row_uri)
        cell_coordinates      = description.fetch(:cell_coordinates)

        fetch_dataset_data(dataset_uri)

        # Per-cell

        coordinate_clauses = cell_coordinates.inject({}) { |clauses, (dimension, value)|
          clauses.merge!(uri(dimension) => uri(value))
        }
        query = RDF::Query.new(
          obs: {
            uri(REF_AREA)             => uri(row_uri),
            uri(measure_property_uri) => :measure,
          }.merge(coordinate_clauses)
        )

        solutions = query.execute(observation_graph)
        if solutions.any?
          solutions.first.measure.object
        end
      end

      private

      def observation_graph
        @observation_graph ||= RDF::Graph.new
      end

      def fetch_dataset_data(dataset_uri)
        triples, values = dimensions_specification.values_at(:triples, :values)

        measure_property_uri = "http://example.com/fake-value-to-let-controller-run"

        query = <<-SPARQL
          CONSTRUCT {
            ?obs <#{measure_property_uri}> ?measure .
            #{triples}
          }
          WHERE {
            ?obs <#{RDF::CUBE.dataSet}> <#{dataset_uri}> .
            ?obs <#{measure_property_uri}> ?measure .
            # Next line is hacked to allow the controller to run without real data in here
            #{triples} #{"." unless triples.blank?}
            #{values}
          }
        SPARQL

        statements = run_query(query)
        observation_graph.insert(*statements)
      end

      def dimensions_specification
        triple_descriptions = [ ]
        values_restrictions = [ ]

        @dimension_values.each_with_index do |(dimension, values), index|
          dim_value = "?dimValue#{index}"
          triple_descriptions << "?obs <#{dimension}> #{dim_value}"
          values_list = values.map { |value| "<#{value}>" }.join(" ")
          values_restrictions << "VALUES #{dim_value} {#{ values_list }}"
        end

        {
          triples: triple_descriptions.join(" . "),
          values: values_restrictions.join(" ")
        }
      end

      def run_query(query)
        response = Tripod::SparqlClient::Query.query(query.to_s, 'application/n-triples')
        parsed = RDF::Reader.for(:ntriples).new(response).each_statement.to_a
        parsed
      end

      def uri(uri_string_representation)
        RDF::URI(uri_string_representation)
      end
    end
  end
end