module PublishMyData

  class SparqlQueryException < StandardError;; end

  class SparqlQuery

    attr_reader :query # the original query string
    attr_reader :query_type # symbol representing the type (:select, :ask etc)
    attr_reader :body # the body of the query
    attr_reader :prefixes # any prefixes the query may have
    attr_reader :request_format # symbol representing the format of the original request

    cattr_accessor :PREFIX_KEYWORDS
    @@PREFIX_KEYWORDS = %w(BASE PREFIX)
    cattr_accessor :KEYWORDS
    @@KEYWORDS = %w(CONSTRUCT ASK DESCRIBE SELECT)

    def initialize(query_string, request_format_symbol = :html)
      @query = query_string
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
      end

      PublishMyData::SparqlQueryResult.new(result_str)
    end

    def paginate(page, per_page, look_ahead=0)
      # make a pagination version and execute that.
      self.as_pagination_query(page, per_page, look_ahead).execute()
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

    # for selects only, turn this into a paginated version. Returns a whole new SparqlQuery object.
    def as_pagination_query(page, per_page, look_ahead=0)

      # only allow for :selects
      raise SparqlQueryException.new("Can't turn this into a subquery") unless self.query_type == :select

      limit = per_page + look_ahead
      offset = per_page * (page-1)
      # wrap it in a subselect with limit and offset
      paginated_query = "SELECT * { #{self.body} } LIMIT #{limit} OFFSET #{offset}"
      # put the prefixes back on the start
      paginated_query = "#{self.prefixes} #{paginated_query}" if self.prefixes

      # return the paginated version
      SparqlQuery.new(paginated_query, self.request_format)
    end

    private

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