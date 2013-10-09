require 'sparql/client'

module PublishMyData
  module Statistics
    class ObservationSource
      def initialize(query_options)
        # @dataset_uri = query_options.fetch(:dataset_uri)
      end

      def measure_property_uris
        results = Tripod::SparqlClient::Query.select <<-SPARQL
          PREFIX qb: <http://purl.org/linked-data/cube#>

          SELECT DISTINCT ?measureProperty WHERE {
            ?measureProperty a qb:MeasureProperty .
            <#{@dataset_uri}> <#{RDF::PMD_DS.graph}> ?datasetGraph .
            GRAPH ?datasetGraph {
              ?obs ?measureProperty ?value .
            }
          }
        SPARQL

        results.map { |result| result['measureProperty']['value'] }
      end

      def observation_value(description)
        # Bring on Ruby 2 and kwargs...
        dataset_uri           = description.fetch(:dataset_uri)
        measure_property_uri  = description.fetch(:measure_property_uri)
        row_type_uri          = description.fetch(:row_type_uri)
        row_uri               = description.fetch(:row_uri)
        # cell_coordinates      = description.fetch(:cell_coordinates)

        statements = run_query(
          SPARQL::Client::Query.
            construct(
              [:obs, uri(measure_property_uri), :measure],
              [:obs, uri(row_type_uri),         :row_uri]
            ).
            where([:obs, RDF::CUBE.dataset,         uri(dataset_uri)]).
            where([:obs, uri(measure_property_uri), :measure]).
            where([:obs, uri(row_type_uri),         :row_uri])
        )

        new_graph = RDF::Graph.new.insert(*statements)
        query = RDF::Query.new(
          obs: {
            uri(row_type_uri)     => uri(row_uri),
            uri(measure_property_uri)  => :measure
          }
        )

        solutions = query.execute(new_graph)
        if solutions.any?
          solutions.first.measure.object
        end
      end

      private

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