require_dependency "publish_my_data/application_controller"

module PublishMyData
  class VocabulariesController < ApplicationController
    include PublishMyData::DataDownload

    def dump
      @vocabulary = Vocabulary.find_by_data_dump(request.url)

      # if we can't find a current download it's cos we haven't generated it yet since ds was modified
      # ... and we should 404.
      url = find_latest_download_url_for_resource(@vocabulary)
      raise Tripod::Errors::ResourceNotFound unless url

      redirect_to url
    end
  end
end