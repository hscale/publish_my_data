require 'active_support/core_ext/numeric/bytes'

module PublishMyData

  class SparqlQueryResultTooLargeException < StandardError; end

  # class to wrap up a string sparql result
  class SparqlQueryResult

    cattr_accessor :MAX_SIZE
    @@MAX_SIZE = 4.megabytes

    attr_reader :result_str

    def initialize(result_str)
      @result_str = result_str

      if self.length > SparqlQueryResult.MAX_SIZE
        raise SparqlQueryResultTooLargeException.new 'The results for this query are too large to return'
      end

    end

    # responds to a bunch of to_x methods to help with rails responders /rendering.
    def length
      self.to_s.length
    end

    def to_s
      self.result_str
    end

    [:csv, :nt, :ttl, :rdf, :text].each do |format|
      define_method :"to_#{format.to_s}" do
        self.to_s
      end
    end

    def to_json(opts={})
      to_s
    end

    def to_xml(opts={})
      to_s
    end

  end

end