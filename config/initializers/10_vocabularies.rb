module RDF
  SITE = RDF::Vocabulary.new("http://#{PublishMyData.local_domain}/def/")
  PMD_DS = RDF::Vocabulary.new("http://publishmydata.com/def/dataset#")
  DCAT = RDF::Vocabulary.new("http://www.w3.org/ns/dcat#")
  VOID = RDF::Vocabulary.new("http://rdfs.org/ns/void#")
end
