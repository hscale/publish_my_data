require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SelectorsController < ApplicationController
    rescue_from Statistics::Selector::InvalidCSVUploadError, with: :invalid_upload
    rescue_from Statistics::Selector::TooManyGSSCodeTypesError, with: :mixed_gss_codes

    def new
      @selector = Statistics::Selector.new
    end

    def preview
      @selector = Statistics::Selector.new_from_csv(params[:csv_upload])

      respond_to do |format|
        format.html
      end
    end

    def create
      @selector = Statistics::Selector.new(params[:statistics_selector])
      @selector.gss_codes = params[:gss_codes].split(', ')
      @selector.save
      redirect_to selector_path(@selector)
    end

    def show
      @selector = Statistics::Selector.find(params[:id])
    end

    private

    def invalid_upload
      flash.now[:error] = 'The uploaded file did not contain valid CSV data, please check and try again.'

      @selector = Statistics::Selector.new
      render :new
    end

    def mixed_gss_codes
      flash.now[:error] = 'The uploaded file should contain GSS codes at either LSOA or Local Authority level.'

      @selector = Statistics::Selector.new
      render :new
    end
  end
end