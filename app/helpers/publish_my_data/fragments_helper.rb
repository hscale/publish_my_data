module PublishMyData
  module FragmentsHelper
    def dom_id_from_uri(uri)
      uri.downcase.gsub('/', '_')
    end
  end
end
