require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json

    # /data/:id (where :id is the dataset 'slug')
    def show
      @dataset = Dataset.find_by_slug(params[:id])

      @dataset.eager_load_object_triples! # for the owner URI label

      @types = RdfType.where('?s a ?uri').graph(@dataset.data_graph_uri).resources

      if request.format && request.format.html?
        @type_resource_counts = {}
        @types.each do |t|
          @type_resource_counts[t.uri.to_s] = Resource.where("?uri a <#{t.uri.to_s}>").graph(@dataset.data_graph_uri).count
        end
      end

      respond_with(@dataset)
    end

    # /data?page=2&per_page=10
    def index
      dataset_criteria = Dataset.all
      @pagination_params = ResourcePaginationParams.from_request(request)
      @datasets = Paginator.new(dataset_criteria, @pagination_params).paginate
      respond_with(@datasets)
    end

    # /data/:id/download
    def download
      s3 = AWS::S3.new
      @dataset = Dataset.find_by_slug(params[:id])

      # find the latest download for this dataset
      # Note, filenames take the format: "dataset_data-<slug>-time.nt.zip"
      prefix = "dataset_data_#{@dataset.slug}_"
      Rails.logger.debug "**PREFIX: #{prefix}"

      downloads = s3.buckets[PublishMyData.dataset_downloads_s3_bucket].objects.with_prefix(prefix).to_a

      Rails.logger.debug "**DOWNLOADS: #{downloads}"

      if downloads.any?
        latest_download = downloads.last
        Rails.logger.debug "**LATEST DOWNLOAD: #{latest_download.key}"
        redirect_to latest_download.public_url.to_s
      else
        raise Tripod::Errors::ResourceNotFound
      end
    end

  end
end
