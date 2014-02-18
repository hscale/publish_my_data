module PublishMyData
  module SparqlHelper
    def link_to_sparql_results_format(text, format, query, pagination_params=nil)
      link_params = {:format => format, :query => query}
      link_params.merge!(:page => pagination_params.page, :per_page => pagination_params.per_page) if pagination_params
      link_to text, link_params
    end

    def url_for_sparql_results_format(format, query, interpolations={})
      interpolations.merge!(:format => format, :query => query, :only_path => false)
      url_for interpolations
    end

  end
end