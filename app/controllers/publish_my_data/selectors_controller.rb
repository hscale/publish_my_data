require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SelectorsController < ApplicationController
    class InvalidCSVUploadError < StandardError; end

    rescue_from InvalidCSVUploadError, with: :invalid_upload
    rescue_from Statistics::GeographyService::TooManyGSSCodeTypesError, with: :mixed_gss_codes

    def new
    end

    def preview
      geography_service = Statistics::GeographyService.new

      # The error handling used to live in the Selector, and I've preserved the
      # use of rescue_from for now, hence catching and raising an error within
      # the controller
      gss_code_candidates =
        begin
          CSV.read(params[:csv_upload].path).map(&:first)
        rescue ArgumentError
          raise InvalidCSVUploadError, "file upload does not contain .csv data"
        end

      data = geography_service.uris_and_geography_type_for_gss_codes(gss_code_candidates)

      @gss_resource_uris  = data.fetch(:gss_resource_uris)
      @non_gss_codes      = data.fetch(:non_gss_codes)
      @geography_type     = data.fetch(:geography_type)

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
      render :new
    end

    def mixed_gss_codes
      flash.now[:error] = 'The uploaded file should contain GSS codes at either LSOA or Local Authority level.'
      render :new
    end
  end
end
