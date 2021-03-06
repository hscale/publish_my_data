module PublishMyData
  module DataCube

    class Cube

      include PublishMyData::CubeResults

      attr_reader :dataset

      def initialize(dataset)
        @dataset = dataset
      end

      def recommended_dimensions
        sorted_dims = dimension_objects

        largest_dimension = sorted_dims.first
        second_largest_dimension = sorted_dims[1]

        locked_dims = {}

        # other dims
        (2...sorted_dims.length).each do |i|
          dim = sorted_dims[i]
          locked_dims[dim.uri] = dim.values.first[:uri]
        end

        {
          rows_dimension: largest_dimension.uri,
          columns_dimension: second_largest_dimension.uri,
          locked_dimensions: locked_dims
        }
      end

      # a collection of dimension properties for this cube
      def dimensions

        query = "PREFIX qb: <http://purl.org/linked-data/cube#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

        SELECT DISTINCT ?uri ?label WHERE {
          ?uri a qb:DimensionProperty .
          OPTIONAL {
            ?uri rdfs:label ?label .
          }
          GRAPH <#{dataset.data_graph_uri}> {
            ?s ?uri ?o .
          }
        }"

        uris_and_labels_only(Tripod::SparqlClient::Query.select(query))
      end

      def dimension_objects
        dim_objs = dimensions.map { |d| PublishMyData::DataCube::Dimension.new(d[:uri], self, d[:label]) }
        dim_objs.sort{ |x,y| y.size <=> x.size } # ordered by size desc
      end

      # the (one and only) area dimenson for this cube.
      def area_dimension

        # NOTE: finds any properties which are any level of descendant of sdmxDim:refArea

        query = "PREFIX qb: <http://purl.org/linked-data/cube#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        PREFIX sdmxDim: <http://purl.org/linked-data/sdmx/2009/dimension#>

        SELECT DISTINCT ?uri ?label WHERE {
                  
          ?uri a ?dimensionType .
          ?uri a qb:DimensionProperty .

          OPTIONAL {
            ?uri rdfs:label ?label .           
          }
          GRAPH <#{dataset.data_graph_uri}> {
            ?s ?uri ?o .
          }
        
          {
            { ?uri rdfs:subPropertyOf+ sdmxDim:refArea }
            UNION
            { ?uri a sdmxDim:refArea }              
          }
        }"

        uris_and_labels_only(Tripod::SparqlClient::Query.select(query)).first
      end

      # the (one and only) measure property for this cube.
      def measure_property

        query = "PREFIX qb: <http://purl.org/linked-data/cube#>
        PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>

        SELECT DISTINCT ?uri ?label WHERE {
          ?uri a qb:MeasureProperty .
          OPTIONAL {
            ?uri rdfs:label ?label .
          }
          GRAPH <#{dataset.data_graph_uri}> {
            ?s ?uri ?o .
          }
        }"

        uris_and_labels_only(Tripod::SparqlClient::Query.select(query)).first
      end

      # For a given row and column dimension,
      # and a hash of locked dimensions {dimension uri => value}
      # Returns an arry of hashes for the page, with one row per item in the array.
      def grid_observations(page, per_page, rows_dimension_uri, columns_dimension_uri, locked_dimensions={}, order_desc=false, order_by_column_uri=nil)
        measure_property_uri = measure_property[:uri].to_s
        sparql = grid_rows_observations_sparql(page, per_page, rows_dimension_uri, columns_dimension_uri, measure_property_uri, locked_dimensions, order_desc, order_by_column_uri)
        results = Tripod::SparqlClient::Query.select(sparql)
        grid_data(results, rows_dimension_uri, columns_dimension_uri)
      end

      # For a given row and column dimension,
      # and a hash of locked dimensions {dimension uri => value}
      def csv_observations(rows_dimension_uri, columns_dimension_uri, locked_dimensions={}, order_desc=false, order_by_column_uri=nil)
        measure_property_uri = measure_property[:uri].to_s

        page = 1
        per_page = 5000
        page_of_results = nil
        results = []

        while page == 1 || page_of_results.size == per_page
          sparql = paged_observations_sparql(page, per_page, rows_dimension_uri, columns_dimension_uri, measure_property_uri, locked_dimensions, order_desc, order_by_column_uri)
          page_of_results = Tripod::SparqlClient::Query.select(sparql)
          results += page_of_results
          page += 1
        end

        csv_data(results, rows_dimension_uri, columns_dimension_uri, locked_dimensions)
      end

      private

      # convert the results in to a csv format.
      def csv_data(sparql_results, rows_dimension_uri, columns_dimension_uri, locked_dimensions)

        grid_data_results = grid_data(sparql_results, rows_dimension_uri, columns_dimension_uri)

        # start the headers off with just the rows dimension label
        header_uris = [nil, nil]
        header_labels = [rows_dimension_uri, (Resource.find(rows_dimension_uri).label || rows_dimension_uri)]

        columns = PublishMyData::DataCube::Dimension.new(columns_dimension_uri, self).values

        columns.each do |col|
          header_uris << col[:uri]
          header_labels << (col[:label].present? ? col[:label] : col[:uri])
        end

        CSV.generate() do |csv|

          csv << ["Generated by #{PublishMyData.local_domain}", Time.now.iso8601]
          csv << [dataset.uri, dataset.title]

          locked_dimensions.each_pair do |dimension_uri, dimension_value_uri|
            dimension_res = Resource.find(dimension_uri) rescue nil
            dimension_value_res = Resource.find(dimension_value_uri) rescue nil
            csv << [((dimension_res && dimension_res.label) || dimension_uri),
              ((dimension_value_res && dimension_value_res.label) || dimension_value_uri)]
          end

          csv << []

          # add another row, with the column header URIs.
          csv << header_uris
          csv << header_labels

          grid_data_results.each do |row|

            row_array = []
            row_array << ( row[rows_dimension_uri] ) # the row uri
            row_array << ( row["rowlabel"].present? ? row["rowlabel"] : row[rows_dimension_uri] ) # the row label

            header_uris[2,header_uris.length-1].each do |h|
              if row[h]
                row_array << row[h][:val]
              else
                row_array << nil
              end
            end

            csv << row_array
          end

        end

      end


      # convert the sparql results into a grid format (array of hashes)
      def grid_data(sparql_results, rows_dimension_uri, columns_dimension_uri)

        rows_hash = {}

        sparql_results.each do |result|
          row_uri = result["row"]["value"]
          column_uri = result["column"]["value"]
          val = result["val"]["value"]
          obs = result["obs"]["value"]
          row_label = result["rowlabel"]["value"] if result["rowlabel"]
          rows_hash[row_uri] ||= {}
          rows_hash[row_uri]["rowlabel"] = row_label
          rows_hash[row_uri][column_uri] = {val: val, obs: obs}
        end

        # we now have a fully popluated rows_hash.
        # {
        #  "row-1-uri": {"col-1-uri": {val: blah, obs: obs-uri}, "col-2-uri": {val: blah, obs: obs-uri},
        #  "row-2-uri": ....
        # }

        # now build the actual rows to return
        rows = []
        rows_hash.each_pair do |row_uri, row_data|

          # init the results row with just the row uri
          row = {}
          row[rows_dimension_uri] = row_uri

          row_data.each_pair do |column_uri, column_value|
            row[column_uri] = column_value
          end

          rows << row
        end

        rows
      end

      # build up a sparql query which gets a page observations (not based on grid rows).
      # this is much quicker than the grid-paged version below.
      def paged_observations_sparql(page, per_page, rows_dimension_uri, columns_dimension_uri, measure_property_uri, locked_dimensions={}, order_desc=false, order_by_column_uri=nil)
        offset = (page-1) * per_page
        order_dir = order_desc ? "DESC" : "ASC"

        sparql = sparql_prefixes

        sparql += "
          SELECT ?row (?firstrowlabel as ?rowlabel) ?column ?obs ?val {

            SELECT ?row (MIN(?rowlabel) as ?firstrowlabel) ?column ?obs ?val WHERE {

              SELECT ?row ?rowlabel ?column ?obs ?val WHERE {
                GRAPH <#{dataset.data_graph_uri.to_s}> {
                  ?obs <#{rows_dimension_uri.to_s}> ?row .
                  ?obs <#{columns_dimension_uri.to_s}> ?column .
                  ?obs <#{measure_property_uri.to_s}> ?val ."

              locked_dimensions.each_pair do |dimension_uri, dimension_value|
                sparql += "
                  ?obs <#{dimension_uri.to_s}> <#{dimension_value.to_s}> . "
              end
              sparql += "
                }
                "
                if order_by_column_uri
                  sparql += optional_column_ordering_clauses(order_by_column_uri, rows_dimension_uri, columns_dimension_uri, measure_property_uri, locked_dimensions)
                end

              sparql += "
                OPTIONAL {
                  ?row rdfs:label ?rowlabel .
                }
              }

            }
            GROUP BY ?row ?column ?obs ?val
          }
          "
        if order_by_column_uri
          sparql += "
            ORDER BY #{order_dir}(?val) "
        else
          sparql += "
            ORDER BY #{order_dir}(?firstrowlabel)" # order by the row labels by default
        end

        sparql += "LIMIT #{per_page} OFFSET #{offset}"

      end

      # build up a sparql query which gets the observations for a set of rows of the cube grid
      def grid_rows_observations_sparql(page, per_page, rows_dimension_uri, columns_dimension_uri, measure_property_uri, locked_dimensions={}, order_desc=false, order_by_column_uri=nil)

        offset = (page-1) * per_page
        order_dir = order_desc ? "DESC" : "ASC"

        sparql = sparql_prefixes
        sparql += "
          SELECT ?row (?firstrowlabel as ?rowlabel) ?column (?o2 as ?obs) (?val2 as ?val)
          WHERE {
            {
              SELECT ?row (MIN(?rowlabel) as ?firstrowlabel) WHERE {
              {
                SELECT DISTINCT ?row
                WHERE {
                  GRAPH <#{dataset.data_graph_uri.to_s}> {
                    ?o <#{rows_dimension_uri.to_s}> ?row . "

          # add the locked dimensions here so that we get the right limited set of rows (the ref dimensions etc might change between years etc).
          locked_dimensions.each_pair do |dimension_uri, dimension_value|
            sparql += "
                  ?o <#{dimension_uri.to_s}> <#{dimension_value.to_s}> . "
          end

          sparql += " }
                }
              }"

        # only need to add these clauses if ordering by a column
        if order_by_column_uri
          sparql += optional_column_ordering_clauses(order_by_column_uri, rows_dimension_uri, columns_dimension_uri, measure_property_uri, locked_dimensions)
        end

        # put the row label constraint in its own optional block
        sparql += "
              OPTIONAL {
                ?row rdfs:label ?rowlabel .
              }
            }

            # group by rows so we can get the first label
            GROUP BY ?row
        "

        if order_by_column_uri
          sparql += "
            ?val # this is an extra group by
            ORDER BY #{order_dir}(?val) "
        else
          sparql += "
            ORDER BY #{order_dir}(?firstrowlabel) " # order by the row labels by default
        end

        sparql += "
            LIMIT #{per_page} OFFSET #{offset}
          }

          GRAPH <#{dataset.data_graph_uri.to_s}> {
            ?o2 <#{rows_dimension_uri.to_s}> ?row .
            ?o2 <#{columns_dimension_uri.to_s}> ?column .
            ?o2 <#{measure_property_uri.to_s}> ?val2 .
          "

        locked_dimensions.each_pair do |dimension_uri, dimension_value|
          sparql += "
            ?o2 <#{dimension_uri.to_s}> <#{dimension_value.to_s}> . "
        end

        sparql += "
            }
          } "
        sparql
      end

      def sparql_prefixes
        "PREFIX qb: <http://purl.org/linked-data/cube#>
          PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
        "
      end

      def optional_column_ordering_clauses(order_by_column_uri, rows_dimension_uri, columns_dimension_uri, measure_property_uri, locked_dimensions)
        sparql = "
          OPTIONAL {
            GRAPH <#{dataset.data_graph_uri.to_s}> {
              ?o3 <#{rows_dimension_uri.to_s}> ?row .
              ?o3 <#{columns_dimension_uri.to_s}> <#{order_by_column_uri.to_s}> .
              ?o3 <#{measure_property_uri.to_s}> ?val . "

        locked_dimensions.each_pair do |dimension_uri, dimension_value|
          sparql += "
            ?o3 <#{dimension_uri.to_s}> <#{dimension_value.to_s}> . "
        end

        sparql += " }
          } "

        return sparql
      end
    end
  end
end