module PublishMyData
  class ThemeRenderParams

    def initialize(resource)
      @resource = resource
      @theme = resource.as_theme
    end

    # e.g. opts[:pagination_params] => ResourcePaginationParams.new
    def render_params(opts={})
      datasets = Paginator.new(@theme.datasets_criteria, opts[:pagination_params]).paginate
      {
         template: 'publish_my_data/themes/show',
         locals: {
           theme: @theme,
           datasets: datasets,
           pagination_params: opts[:pagination_params]
         }
      }
    end

  end
end