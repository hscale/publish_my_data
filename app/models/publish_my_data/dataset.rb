module PublishMyData
  class Dataset
    include Tripod::Resource
    include DatasetPowers

    rdf_type RDF::PMD_DS.Dataset
    deprecated_rdf_type RDF::PMD_DS.DeprecatedDataset
  end
end