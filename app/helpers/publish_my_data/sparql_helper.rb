module PublishMyData
  module SparqlHelper
    def link_to_sparql_results_format(text, format, query)
      link_to text, :format => format, :query => query, :page => @page, :per_page => @per_page
    end
  end
end