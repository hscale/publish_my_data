module PublishMyData
  module SparqlHelper
    def link_to_sparql_results_format(text, format, query)
      link_to text, :format => format, :query => query
    end

    def more_sparql_result_pages?
      # see if looking ahead by 1 yields an extra result
      @sparql_query.as_pagination_query(@page, @per_page, 1).count > @per_page
    end
  end
end