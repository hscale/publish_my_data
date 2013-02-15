require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    # /datasets/:id (where :id is the dataset 'slug')
    def show
      @dataset = Dataset.find_by_slug(params[:id])
    end

    # /datasets?filter=value
    def index
      # TODO:
      # show all the datasets.
      # deal with pagination
    end

  end
end
