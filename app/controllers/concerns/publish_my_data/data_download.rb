module PublishMyData
  module DataDownload
    def find_latest_download_url_for_resource(resource)
      # find the latest download for this dataset
      # Note: filenames on s3 take the format: "<prefix>_<slug>_<time>.nt.zip"
      # Only look for ones that were made on the same day as the the modified date, to restrict the results
      # (v. small possibility of errors for changes aroung midnight, but unlikely people will be changing datasets then anyway!)
      s3 = AWS::S3.new
      downloads = s3.buckets[PublishMyData.downloads_s3_bucket].objects.with_prefix(resource.download_prefix).to_a

      download_url = nil
      if downloads.any?
        download_url = downloads.last.public_url.to_s
      end
      download_url
    end

    def type_for_resource(resource)
      resource.class.name.demodulize.underscore # ontology, concept_scheme or vocabulary
    end
  end
end