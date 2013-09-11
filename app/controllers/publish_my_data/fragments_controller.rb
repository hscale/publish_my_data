require_dependency "publish_my_data/application_controller"

module PublishMyData
  class FragmentsController < ApplicationController
    before_filter :get_selector, :get_dataset, only: [ :new, :create ]

    def datasets
      @datasets = Dataset.data_cubes
    end

    def new
      @fragment = Statistics::Fragment.new(@selector, @dataset)
    end

    def create
      @fragment = Statistics::Fragment.new(@selector, @dataset, params[:dataset_dimensions])

      if @fragment.save
        redirect_to selector_path(@selector)
      end
    end

    private

    def get_selector
      @selector = Statistics::Selector.find(params[:selector_id])
    end

    def get_dataset
      @dataset = Dataset.find(params[:dataset_uri])
    end
  end
end
