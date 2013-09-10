require_dependency "publish_my_data/application_controller"

module PublishMyData
  class FragmentsController < ApplicationController
    def new
      @datasets = Dataset.data_cubes.resources
      logger.info "MOO"
      logger.info @datasets.inspect
    end
  end
end
