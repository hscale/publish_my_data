# A generic vocabulary class, used to retrieve/differentiate third-party vocabularies (ontologies *and* concept schemes)
module PublishMyData
  class Vocabulary
    include Tripod::Resource
    include AllFeatures

    # override
    def slug
      uri_hash(self.uri)
    end

    private

    def uri_hash(uri)
      Digest::SHA1.hexdigest(uri)
    end
  end
end