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
        @row_dimension  = query_options.fetch(:row_dimension)
        @row_uris       = query_options.fetch(:row_uris)

        @datasets       = query_options.fetch(:datasets)
      end

      def observation_value(description)
        measure_property_uri  = description.fetch(:measure_property_uri)
        row_uri               = description.fetch(:row_uri)
        cell_coordinates      = description.fetch(:cell_coordinates)

        coordinate_clauses = cell_coordinates.reduce({}) { |clauses, (dimension, value)|
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
        @observation_graph ||= begin
          RDF::Graph.new.tap { |graph| load_dataset_data_into_graph(graph) }
        end
      end

      def load_dataset_data_into_graph(graph)
        @datasets.each do |dataset|
          dataset_uri           = dataset.fetch(:dataset_uri)
          measure_property_uri  = dataset.fetch(:measure_property_uri)
          dimensions            = dataset.fetch(:dimensions)

          dimensions_with_rows  = dimensions.merge(@row_dimension => @row_uris)

          load_single_dataset_data_into_graph(graph, dataset_uri, measure_property_uri, dimensions_with_rows)
        end
      end

      def load_single_dataset_data_into_graph(graph, dataset_uri, measure_property_uri, dimensions)
        triples, values = dimensions_query_fragments(dimensions).values_at(:triples, :values)

        query = <<-SPARQL
          CONSTRUCT {
            ?obs <#{measure_property_uri}> ?measure .
            #{triples}
          }
          WHERE {
            ?obs <#{RDF::CUBE.dataSet}> <#{dataset_uri}> .
            ?obs <#{measure_property_uri}> ?measure .
            #{triples} #{"." unless triples.blank?}
            #{values}
          }
        SPARQL

        graph.insert(*query_result_statements(query))
      end

      def dimensions_query_fragments(dimensions)
        triples = [ ]
        value_tables = [ ]

        dimensions.each_with_index do |(dimension, values), index|
          dim_value = "?dimValue#{index}"
          triples << "?obs <#{dimension}> #{dim_value}"
          values_list = values.map { |value| "<#{value}>" }.join(" ")
          value_tables << "VALUES #{dim_value} {#{values_list}}"
        end

        { triples: triples.join(" . "), values: value_tables.join(" ") }
      end

      def query_result_statements(query)
        ntriples_data = Tripod::SparqlClient::Query.query(query.to_s, 'application/n-triples')
        RDF::Reader.for(:ntriples).new(ntriples_data).each_statement.to_a
      end

      def uri(uri_string_representation)
        RDF::URI(uri_string_representation)
      end
    end
  end
end