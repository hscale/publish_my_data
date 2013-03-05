module PublishMyData

  class PaginationParams

    DEFAULT_PAGE_SIZE = 20
    MAX_PAGE_SIZE = 10000

    attr_accessor :page
    attr_accessor :per_page
    attr_accessor :offset
    attr_accessor :format

    # example opts:
    #  {:per_page => 10, :page => 2, :format => :html}
    def initialize(opts={})
      self.per_page = (opts[:per_page] || PaginationParams::DEFAULT_PAGE_SIZE).to_i
      self.per_page = PaginationParams::MAX_PAGE_SIZE if self.per_page > PaginationParams::MAX_PAGE_SIZE
      self.page = (opts[:page] || 1).to_i
      self.offset = self.per_page.to_i * (self.page.to_i-1)
      self.format = opts[:format]
    end

    def self.from_request(request)
      PaginationParams.new(per_page: request.params[:per_page], page: request.params[:page], format: request.format.to_sym)
    end

    def ==(other)
      other.page == self.page &&
        other.per_page == self.per_page &&
        other.format == self.format
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
      resources = criteria.limit(self.pagination_params.per_page).offset(self.pagination_params.offset).resources

      if self.pagination_params.format == :html
        Kaminari.paginate_array(resources.to_a, total_count: count).page(self.pagination_params.page).per(self.pagination_params.per_page)
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