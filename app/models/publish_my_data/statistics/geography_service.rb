module PublishMyData
  module Statistics
    # As the name suggests, we may be better with a services/ folder
    # when we extract the Stats Selector into its own engine
    class GeographyService
      class TooManyGSSCodeTypesError < StandardError; end

      def uris_and_geography_type_for_gss_codes(gss_code_candidates)
        gss_codes, gss_resource_uris, geography_types = gss_codes_and_uris(gss_code_candidates)
        non_gss_codes = gss_code_candidates - gss_codes
        raise TooManyGSSCodeTypesError unless (geography_types.size == 1)

        {
          gss_resource_uris:  gss_resource_uris,
          non_gss_codes:      non_gss_codes,
          geography_type:     geography_types.first
        }
      end

      private

      def gss_codes_and_uris(gss_codes)
        gss_code_string = gss_codes.map{ |code| %'"#{code}"'}.join(' ')

        query_results = Tripod::SparqlClient::Query.select(<<-SPARQL
          SELECT DISTINCT ?uri ?code ?type
          WHERE {
            {
              ?uri a <http://opendatacommunities.org/def/geography#LSOA> .
              ?uri <http://www.w3.org/2004/02/skos/core#notation> ?code .
            } UNION {
              ?uri a <http://statistics.data.gov.uk/def/statistical-geography> .
              ?uri <http://data.ordnancesurvey.co.uk/ontology/admingeo/gssCode> ?code .
            }
            ?uri a ?type .
            VALUES ?code {#{gss_code_string}}
          }
          SPARQL
        )

        query_results.reduce([[], [], Set.new]) { |(codes, uris, types), result|
          codes << result['code']['value']
          uris  << result['uri']['value']
          types << result['type']['value']
          [codes, uris, types]
        }.tap { |results|
          results[2] = results[2].to_a
        }
      end
    end
  end
end