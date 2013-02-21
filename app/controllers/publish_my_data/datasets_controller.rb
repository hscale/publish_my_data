require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    # /datasets/:id (where :id is the dataset 'slug')
    def show
      @dataset = Dataset.find_by_slug(params[:id])
    end

    # /datasets?_page=2&_per_page=10
    def index
      get_page_params

      datasets = Dataset.all.limit(@limit).offset(@offset).resources
      @count = Dataset.count

      @datasets = Kaminari.paginate_array(datasets, total_count: @count).page(@page).per(@limit)
    end

    private

    def get_page_params
      @limit = (params[:_per_page] || 20).to_i
      @page = (params[:_page] || 1).to_i
      @offset = @limit.to_i * (@page.to_i-1)
    end

  end
end
