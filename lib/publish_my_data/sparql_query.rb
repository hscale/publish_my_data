
module PublishMyData

  class SparqlQueryException < StandardError; end
  class SparqlQueryExecutionException < StandardError; end

  class SparqlQuery

    attr_reader :query # the original query string
    attr_reader :query_type # symbol representing the type (:select, :ask etc)
    attr_reader :body # the body of the query
    attr_reader :prefixes # any prefixes the query may have
    attr_reader :request_format # symbol representing the format of the original request
    attr_reader :parent_query # set if this query originated from another (e.g. pagination or count)

    cattr_accessor :PREFIX_KEYWORDS
    @@PREFIX_KEYWORDS = %w(BASE PREFIX)
    cattr_accessor :KEYWORDS
    @@KEYWORDS = %w(CONSTRUCT ASK DESCRIBE SELECT)

    def initialize(query_string, request_format_symbol = :html, parent_query = nil)
      @query = query_string
      @parent_query = parent_query

      @request_format = request_format_symbol

      if self.has_prefixes?
        @prefixes, @body = self.extract_prefixes
      else
        @body = self.query
      end

      @query_type = get_query_type
    end

    # executes the query, using the right format parameters (for fuseki) for the query type and request format
    def execute

      begin
        case query_type
          when :select
            result_str = Tripod::SparqlClient::Query.select(self.query, select_format_str)
          when :ask
            result_str = Tripod::SparqlClient::Query.ask(self.query, ask_format_str)
          when :construct
            result_str = Tripod::SparqlClient::Query.construct(self.query, construct_or_describe_header)
          when :describe
            result_str = Tripod::SparqlClient::Query.describe(self.query, construct_or_describe_header)
          else
            raise SparqlQueryExecutionException.new("Unsupported Query Type. Please enter only SELECT, CONSTRUCT, DESCRIBE or ASK queries.")
        end

      rescue Tripod::Errors::SparqlParseFailed => spe
        if self.parent_query
          # call execute on the parent(this will fail too), but it means that we get the right error for
          # the user-entered query
          parent_query.execute
        else
          raise SparqlQueryExecutionException.new(process_sparql_parse_failed_exception_message(spe))
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

    def has_prefixes?
      self.class.PREFIX_KEYWORDS.each do |k|
        return true if /^#{k}/i.match(query)
      end
      return false
    end

    def extract_prefixes
      i = self.class.KEYWORDS.map {|k| self.query.index(/#{k}/i) || self.query.size+1 }.min
      p = query[0..i-1]
      b = query[i..-1]
      return p.strip, b.strip
    end

    def allow_pagination?
      self.query_type == :select
    end

    def as_count_query(format = :json)
      # only allow for selects
      raise SparqlQueryException.new("Can't turn this into a subquery") unless self.query_type == :select

      count_query = "SELECT COUNT(*) { #{self.body} }"
      count_query = "#{self.prefixes} #{count_query}" if self.prefixes

      # return the paginated version
      SparqlQuery.new(count_query, format, self) # pass in the original query
    end

    # for selects only, turn this into a paginated version. Returns a whole new SparqlQuery object.
    def as_pagination_query(page, per_page, look_ahead=0)

      # only allow for selects
      raise SparqlQueryException.new("Can't turn this into a subquery") unless self.query_type == :select

      limit = per_page + look_ahead
      offset = per_page * (page-1)
      # wrap it in a subselect with limit and offset
      paginated_query = "SELECT * { #{self.body} } LIMIT #{limit} OFFSET #{offset}"
      # put the prefixes back on the start
      paginated_query = "#{self.prefixes} #{paginated_query}" if self.prefixes

      # return the paginated version
      SparqlQuery.new(paginated_query, self.request_format, self) # pass in the original query
    end

    private

    def process_sparql_parse_failed_exception_message(sparql_parse_failed_exception)
      message = sparql_parse_failed_exception.message
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

    def get_query_type
      if /^CONSTRUCT/i.match(self.body)
        :construct
      elsif /^ASK/i.match(self.body)
        :ask
      elsif /^DESCRIBE/i.match(self.body)
        :describe
      elsif /^SELECT/i.match(self.body)
        :select
      else
        :unknown
      end
    end

  end

end