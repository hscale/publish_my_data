module PublishMyData
  module DataCube

    class Dimension

      include PublishMyData::CubeResults

      attr_reader :uri
      attr_reader :cube

      PAGE_SIZE = 5000

      def initialize(uri, cube)
        @uri = uri
        @cube = cube
      end

      # get all the possible values (uris and labels) for this dimension in the dataset passed in.
      # paginates internally if necessary.
      def values
        sparql = values_sparql(labels:true)
        results = loop_and_page_sparql_query(sparql) # by default this tries 5000 rows at a time.
        uris_and_labels_only(results)
      end

      def size
        # don't get labels and don't paginate.
        sparql = values_sparql({labels:false})
        sq = Tripod::SparqlQuery.new(sparql)
        count_sparql = sq.as_count_query_str
        result = Tripod::SparqlClient::Query.select(count_sparql)
        result[0]["tripod_count_var"]["value"].to_i
      end

      private

      def values_sparql(opts={})
        labels = opts[:labels]

        sparql = "PREFIX qb: <http://purl.org/linked-data/cube#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        SELECT DISTINCT ?uri #{labels ? '?label' : ""} WHERE {
          GRAPH <#{cube.dataset.data_graph_uri.to_s}> {
            ?obs qb:dataSet <#{cube.dataset.uri.to_s}> .
            ?obs <#{self.uri.to_s}> ?uri .
          }
        "
        sparql += "OPTIONAL { ?uri rdfs:label ?label . } " if labels
        sparql += " } "
        sparql += " ORDER BY #{labels ? '?label' : ''} ?uri"
        sparql
      end



    end
  end
end
