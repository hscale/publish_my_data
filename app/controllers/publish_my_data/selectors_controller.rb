require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SelectorsController < ApplicationController
    def new
      selector = Statistics::Selector.create
      redirect_to selector_path(selector)
    end

    def show
      @selector = Statistics::Selector.find(params[:id])
    end
  end
end
