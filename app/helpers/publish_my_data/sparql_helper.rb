module PublishMyData
  module SparqlHelper
    def link_to_sparql_results_format(text, format, query)
      link_to text, :format => format, :query => query, :_page => @page, :_per_page => @per_page
    end
  end
end