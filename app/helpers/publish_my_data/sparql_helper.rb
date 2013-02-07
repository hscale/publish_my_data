module PublishMyData
  module SparqlHelper
    def link_to_sparql_results_format(text, format, query)
      link_to text, :format => format, :query => query
    end
  end
end