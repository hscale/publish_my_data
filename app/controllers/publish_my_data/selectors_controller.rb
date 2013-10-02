require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SelectorsController < ApplicationController
    rescue_from Statistics::Selector::InvalidCSVUploadError, with: :invalid_upload
    rescue_from Statistics::Selector::TooManyGSSCodeTypesError, with: :mixed_gss_codes

    def new
    end

    def preview
      # TODO: process_csv
      @gss_resource_uris, @non_gss_codes, @geography_type = Statistics::Selector.process_csv(params[:csv_upload])
      @gss_resource_uri_data = @gss_resource_uris.join(', ')

      respond_to do |format|
        format.html
      end
    end

    def create
      gss_resource_uris = params[:gss_resource_uri_data].split(', ')

      @selector = Statistics::Selector.create(
        geography_type: params[:geography_type],
        row_uris:       gss_resource_uris
      )

      redirect_to selector_path(@selector)
    end

    def show
      @selector = Statistics::Selector.find(params[:id])
      @observation_source =
        Statistics::Selector::ObservationSource.new(@selector.query_options)

      # Maybe...?
      # @selector_snapshot =
      #   @selector.take_snapshot(
      #     labeller: Labeller.new,
      #     observation_source: ObservationSource.new
      #   )
    end

    private

    def row_uris
      Resource.find_by_sparql("
        SELECT distinct ?uri
        WHERE { ?uri a <http://statistics.data.gov.uk/def/statistical-geography>. }
        LIMIT 10
      ").map(&:uri)
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
