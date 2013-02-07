module PublishMyData

  # class to wrap up a string sparql result
  class SparqlQueryResult

    attr_reader :result_str

    def initialize(result_str)
      @result_str = result_str
    end

    # responds to a bunch of to_x methods to help with rails responders /rendering.

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