require_dependency "publish_my_data/application_controller"

module PublishMyData
  class DatasetsController < ApplicationController

    respond_to :html, :ttl, :rdf, :nt, :json, :text

    # /data/:id (where :id is the dataset 'slug')
    def show

      @dataset = Dataset.find_by_slug(params[:id])

      @dataset.eager_load_object_triples!(:labels_only => true) # for the owner URI label

      @types = RdfType.where('?s a ?uri').graph(@dataset.data_graph_uri).resources

      if is_request_html_format?
        @type_resource_counts = {}
        @resources_count = 0
        @types.each do |t|
          count_query = "SELECT ?uri WHERE { GRAPH <#{@dataset.data_graph_uri.to_s}> { ?uri a <#{t.uri.to_s}> } }"
          @type_resource_counts[t.uri.to_s] = SparqlQuery.new(count_query).count
          @resources_count += @type_resource_counts[t.uri.to_s]
        end

      end

      respond_with(@dataset)
    end

    # /data?page=2&per_page=10
    def index
      dataset_criteria = Dataset.ordered_datasets_criteria
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

      # filter the downloads to only include ones with a timestamp equal to or after the dataset modified date.
      # (ones older than this are out of date)
      current_downloads = downloads.select do |d|
        date_portion = d.public_url.to_s.split("_").last.split('.').first  #between last underscore and first dot.
        file_timestamp = DateTime.parse(date_portion)
        file_timestamp >= @dataset.modified
      end

      # if we can't find a current download it's cos we haven't generated it yet since ds was modified
      # ... and we should 404.
      if current_downloads.any?
        latest_download = current_downloads.last
        redirect_to latest_download.public_url.to_s
      else
        raise Tripod::Errors::ResourceNotFound
      end
    end

  end
end
