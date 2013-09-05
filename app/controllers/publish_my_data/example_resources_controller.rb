module PublishMyData
  class ExampleResourcesController < ApplicationController
    def index
      @dataset = Dataset.find_by_slug(params[:id])

      respond_to do |format|
        format.js {}
      end
    end
  end
end