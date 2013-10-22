module PublishMyData
  module Statistics
    # As the name suggests, we may be better with a services/ folder
    # when we extract the Stats Selector into its own engine
    class GeographyService
      class TooManyGSSCodeTypesError < StandardError; end
      class TooManyGSSCodesError < StandardError; end

      cattr_accessor :MAX_NUMBER_OF_GSS_CODES
      @@MAX_NUMBER_OF_GSS_CODES = 500

      def uris_and_geography_type_for_gss_codes(gss_code_candidates)
        gss_codes, gss_resource_uris, geography_types = gss_codes_and_uris(gss_code_candidates)
        raise TooManyGSSCodesError if gss_codes.size > self.class.MAX_NUMBER_OF_GSS_CODES

        non_gss_codes = gss_code_candidates - gss_codes
        raise TooManyGSSCodeTypesError unless (geography_types.size == 1)

        {
          gss_resource_uris:  gss_resource_uris,
          non_gss_codes:      non_gss_codes,
          geography_type:     geography_types.first
        }
      end

      def self.geographical_data_cubes(geo_uri)
        filter_triples = case geo_uri
          when "http://opendatacommunities.org/def/geography#LSOA"
            "?o a <http://opendatacommunities.org/def/geography#LSOA> ."
          when "http://opendatacommunities.org/def/local-government/LocalAuthority"
            "?la a <http://opendatacommunities.org/def/local-government/LocalAuthority> . ?la <http://opendatacommunities.org/def/local-government/governsGSS> ?o ."
        end
        Dataset.find_by_sparql("
          SELECT DISTINCT ?uri WHERE {
            #{ filter_triples }
            ?s <http://opendatacommunities.org/def/ontology/geography/refArea> ?o .
            ?uri a <#{RDF::PMD_DS.Dataset}> .
            ?s <#{ RDF::CUBE.dataSet }> ?uri .
          }
        ")
      end

      private

      def gss_codes_and_uris(gss_codes)
        gss_code_string = gss_codes.map{ |code| %'"#{code}"'}.join(' ')

        query_results = Tripod::SparqlClient::Query.select(<<-SPARQL
          SELECT DISTINCT ?uri ?code ?type
          WHERE {
            {
              ?uri a <http://opendatacommunities.org/def/geography#LSOA> .
              ?uri a ?type .
              ?uri <http://www.w3.org/2004/02/skos/core#notation> ?code .
            } UNION {
              ?la a <http://opendatacommunities.org/def/local-government/LocalAuthority> .
              ?la a ?type .
              ?la <http://opendatacommunities.org/def/local-government/governsGSS> ?uri .
              ?uri <http://data.ordnancesurvey.co.uk/ontology/admingeo/gssCode> ?code .
            }
            VALUES ?code {#{gss_code_string}}
            VALUES ?type {<http://opendatacommunities.org/def/geography#LSOA> <http://opendatacommunities.org/def/local-government/LocalAuthority>}
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