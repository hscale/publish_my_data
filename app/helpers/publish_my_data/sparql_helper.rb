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

    def default_prefixes
      prefix_string = ""
      PublishMyData.prefixes.each do |key, value|
          prefix_string += "PREFIX #{key}: <#{value}>\n"
      end
      prefix_string
    end

    def default_query()
      default_prefixes + "\nSELECT DISTINCT *\nWHERE {\n  ?s ?p ?o\n}\nLIMIT 20"
    end

    def default_query_with_graph
      default_prefixes + "\nSELECT DISTINCT *\nWHERE {\n  GRAPH <%{graph}> {\n    ?s ?p ?o\n  }\n}\nLIMIT 20"
    end

  end
end
