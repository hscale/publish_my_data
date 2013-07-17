# A generic vocabulary class, used to retrieve/differentiate third-party vocabularies (ontologies *and* concept schemes)
module PublishMyData
  class Vocabulary
    include Tripod::Resource
    include AllFeatures

    def self.find_by_data_dump(data_dump_uri)
      all.where("?uri <#{RDF::VOID.dataDump}> <#{data_dump_uri}>").first
    end

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