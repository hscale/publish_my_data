require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    caches_action :show, :index, :cache_path => Proc.new { |c| [c.params, c.request.format] }

    # /data/:id (where :id is the dataset 'slug')
    def show

      Rails.logger.debug request.params.to_s

      @dataset = Dataset.find_by_slug(params[:id])

      @dataset.eager_load_object_triples!(:labels_only => true) # for the owner URI label

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

    # /data/:id/dump
    def dump
      s3 = AWS::S3.new
      @dataset = Dataset.find_by_slug(params[:id])

      # find the latest download for this dataset
      # Note: filenames on s3 take the format: "dataset_data_<slug>_time.nt.zip"
      # Only look for ones that were made on the same day as the the modified date, to restrict the results
      # (v. small possibility of errors for changes aroung midnight, but unlikely people will be changing datasets then anyway!)
      prefix = "dataset_data_#{@dataset.slug}_#{@dataset.modified.strftime("%Y%m%d")}"
      downloads = s3.buckets[PublishMyData.dataset_downloads_s3_bucket].objects.with_prefix(prefix).to_a

      if downloads.any?
        latest_download = downloads.last
        redirect_to latest_download.public_url.to_s
      else
        raise Tripod::Errors::ResourceNotFound
      end
    end

  end
end
