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
      self.new(per_page: request.params[:per_page], page: request.params[:page], format: request.format.to_sym)
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
    attr_accessor :criteria

    def initialize(criteria, pagination_params)
      self.criteria = criteria
      self.pagination_params = pagination_params
    end

    # returns a Kaminari paginatable array, or a plain old array
    def paginate
      count = criteria.count #this has to happen first, before we modify the criteria with limit/offset

      Rails.logger.debug "per page: #{self.pagination_params.per_page}"
      criteria.limit(self.pagination_params.per_page) if self.pagination_params.per_page
      criteria.offset(self.pagination_params.offset) if self.pagination_params.offset
      resources = criteria.resources

      if self.pagination_params.format == :html && pagination_params.per_page && pagination_params.page
        paginatable = Kaminari.paginate_array(resources.to_a, total_count: count).page(self.pagination_params.page).per(self.pagination_params.per_page)
      else
        resources # non html versions just need the raw array
      end
    end

    def ==(other)
      self.pagination_params == other.pagination_params &&
        self.criteria == other.criteria
    end

  end
end