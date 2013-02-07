module PublishMyData

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


    private

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