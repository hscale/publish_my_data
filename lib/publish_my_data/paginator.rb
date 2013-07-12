module PublishMyData

  class PaginationParams

    attr_accessor :page
    attr_accessor :per_page
    attr_accessor :offset
    attr_accessor :format

    # example opts:
    #  {:per_page => 10, :page => 2, :format => :html}
    def initialize(opts={})
      self.per_page = (opts[:per_page]).to_i if opts[:per_page]
      self.page = (opts[:page] || 1).to_i
      self.offset = self.per_page.to_i * (self.page.to_i-1) if self.per_page
      self.format = opts[:format]
    end

    def self.from_request(request)
      self.new(per_page: request.params[:per_page], page: request.params[:page], format: (request.format.to_sym || :html))
    end

    def ==(other)
      other.page == self.page &&
        other.per_page == self.per_page &&
        other.format == self.format
    end

  end

  class SparqlPaginationParams < PaginationParams

    def initialize(opts={})
      opts[:per_page] ||= PublishMyData.default_html_sparql_per_page if opts[:format] == :html
      super
    end

  end

  class ResourcePaginationParams < PaginationParams

    def initialize(opts={})
      opts[:per_page] ||= PublishMyData.default_html_resources_per_page
      opts[:per_page] = PublishMyData.max_resources_per_page if opts[:per_page].to_i > PublishMyData.max_resources_per_page
      super
    end
  end

  class Paginator

    attr_accessor :pagination_params
    attr_accessor :resource_class
    attr_accessor :sparql_query # PublishMyData::SparqlQuery

    # criteria can be a Tripod::Criteria or a sparql string.
    # pagination_params should be an instance pagination params.
    # if criteria is a sparql string, optionally pass options[:resource_class] to dictate what type of objects to return (else it will return Resources)
    def initialize(criteria, pagination_params, opts={})

      if criteria.class == String
        self.sparql_query = PublishMyData::SparqlQuery.new(criteria)
        self.resource_class = opts[:resource_class] || PublishMyData::Resource
      elsif criteria.class == Tripod::Criteria
        # Note that this uses the :return_graph => false option for criteria execution to avoid duplicate graphs in the results
        self.sparql_query = PublishMyData::SparqlQuery.new(criteria.as_query(:return_graph => false))
        self.resource_class = criteria.resource_class
      end

      self.pagination_params = pagination_params
    end

    # returns a Kaminari paginatable array (for html), or a plain old array (for data formats)
    def paginate(force_total_count=nil)

      page = self.pagination_params.page
      per_page = self.pagination_params.per_page
      pagination_query_str = self.sparql_query.as_pagination_query(page, per_page).query

      if self.pagination_params.format == :html
        total_count = force_total_count || self.sparql_query.count
        page_of_results = resource_class.find_by_sparql(pagination_query_str)
        Kaminari.paginate_array(page_of_results, total_count: total_count).page(page).per(per_page)
      else
        page_of_results = resource_class.find_by_sparql(pagination_query_str)

        Tripod::ResourceCollection.new(
          page_of_results,
          :return_graph => false,
          :sparql_query_str => pagination_query_str,
          :resource_class => self.resource_class
        )

      end

    end

    def ==(other)
      self.pagination_params == other.pagination_params &&
        self.sparql_query == other.sparql_query  &&
        self.resource_class == self.resource_class
    end

  end
end