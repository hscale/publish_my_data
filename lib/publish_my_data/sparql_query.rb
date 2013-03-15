module PublishMyData

  class SparqlQueryExecutionException < StandardError; end

  class SparqlQueryMissingVariablesException < StandardError
    attr_reader :missing_variables, :expected_variables

    def initialize(missing_variables, expected_variables)
      raise ArgumentError.new("Missing parameters should be an array") unless missing_variables.is_a?(Array)
      @missing_variables = missing_variables
      @expected_variables = expected_variables
    end

    def to_s
      "Missing parameters for interpolation: #{@missing_variables.map(&:to_s).join(', ')}"
    end
  end

  class SparqlQuery < Tripod::SparqlQuery

    attr_reader :request_format # symbol representing the format of the original request
    attr_reader :parent_query # set if this query originated from another (e.g. pagination or count)

    attr_reader :interpolations # interpolations supplied at construct-time
    attr_reader :expected_variables # list of variables used in the query,

    # options
    #  :request_format (symbol, e.g. :html, :json )
    #  :parent_query
    #  :interpolations => { :a => 'blah', :b => 'bleh' }
    def initialize(query_string, opts={})
      @opts = opts # save off the original opts

      @interpolations = opts[:interpolations] || {}

      # modify the query string, before constructing
      query_string = interpolate_query(query_string, self.interpolations)

      super(query_string)

      @parent_query = opts[:parent_query]
      @request_format = opts[:request_format] || :html
    end

    # executes the query, using the right format parameters (for fuseki) for the query type and request format
    def execute
      begin
        case query_type
          when :select
            result_str = Tripod::SparqlClient::Query.query(self.query, "*/*", {:output => select_format_str} )
          when :ask
            result_str = Tripod::SparqlClient::Query.query(self.query, "*/*", {:output => ask_format_str} )
          when :construct
            result_str = Tripod::SparqlClient::Query.query(self.query, construct_or_describe_header)
          when :describe
            result_str = Tripod::SparqlClient::Query.query(self.query, construct_or_describe_header)
          else
            raise SparqlQueryExecutionException.new("Unsupported Query Type. Please enter only SELECT, CONSTRUCT, DESCRIBE or ASK queries.")
        end

      rescue Tripod::Errors::BadSparqlRequest => bad_sparql
        if self.parent_query
          # call execute on the parent(this will fail too), but it means that we get the right error for
          # the user-entered query
          parent_query.execute
        else
          raise SparqlQueryExecutionException.new(process_sparql_parse_failed_exception_message(bad_sparql))
        end
      end

      PublishMyData::SparqlQueryResult.new(result_str)
    end

    # make a pagination version and execute that.
    def paginate(page, per_page, look_ahead=0)
      self.as_pagination_query(page, per_page, look_ahead).execute
    end

    # return the number of results that this query returns
    # (creates and executes a count query behind the scenes)
    def count
      result = JSON.parse(self.as_count_query.execute.to_s)["results"]["bindings"]
      result[0][".1"]["value"].to_i
    end

    def allow_pagination?
      self.query_type == :select
    end

    def as_count_query(format = :json)
      # return the paginated version
      PublishMyData::SparqlQuery.new(as_count_query_str, {:request_format => format, :parent_query => self}) # pass in the original query
    end

    # for selects only, turn this into a paginated version. Returns a whole new SparqlQuery object.
    def as_pagination_query(page, per_page, look_ahead=0)

      check_subqueryable!

      limit = per_page + look_ahead
      offset = per_page * (page-1)
      # wrap it in a subselect with limit and offset
      paginated_query = "SELECT * { #{self.body} } LIMIT #{limit} OFFSET #{offset}"
      # put the prefixes back on the start
      paginated_query = "#{self.prefixes} #{paginated_query}" if self.prefixes

      # return the paginated version
      PublishMyData::SparqlQuery.new(paginated_query, {:request_format => self.request_format, :parent_query => self}) # pass in the original query
    end

    def self.get_expected_variables(query_string)
      query_string.scan(/[.]?\%\{(\w+)\}[.]?/).flatten.uniq.map &:to_sym
    end

    private

    def interpolate_query(query_string, interpolations)
      i = interpolations.symbolize_keys.select{ |k,v| v && v.length > 0 }
      # regular expression finds words inside %{variable} tokens
      @expected_variables = self.class.get_expected_variables(query_string)
      missing_variables = @expected_variables - i.keys
      if missing_variables.length > 0
        raise SparqlQueryMissingVariablesException.new(missing_variables, @expected_variables)
      end
      query_string % i # do the interpolating
    end

    def process_sparql_parse_failed_exception_message(bad_sparql_request)
      message = bad_sparql_request.message
      start = message.index(query) + query.size
      finish = message.index('Fuseki')-1 || (message.length-1)
      message[start..finish].strip
    end

    def select_format_str
      if [:json, :csv, :xml, :text].include?(request_format)
        self.request_format.to_s
      else
        'text'
      end
    end

    def ask_format_str
      if [:json, :xml, :text].include?(request_format)
        self.request_format.to_s
      else
        'text'
      end
    end

    def construct_or_describe_header
      if [:nt, :ttl, :rdf].include?(request_format)
        Mime::Type.lookup_by_extension( request_format.to_s )
      else
        Mime::NT
      end
    end

  end

end