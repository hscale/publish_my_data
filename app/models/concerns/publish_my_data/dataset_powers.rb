module PublishMyData
  module DatasetPowers
    extend ActiveSupport::Concern

    included do
      include PublishMyData::AllFeatures
      field :theme, RDF::DCAT.theme, :is_uri => true
    end

    def metadata_graph_uri
      self.class.metadata_graph_uri(self.slug)
    end

    def to_param
      slug
    end

    def resources_in_dataset_criteria
      Resource.all.graph(self.data_graph_uri)
    end

    def types
      @types ||= RdfType.where('?s a ?uri').graph(self.data_graph_uri).resources
    end

    def type_count(type_uri)
      count_query = "SELECT ?uri WHERE { GRAPH <#{self.data_graph_uri.to_s}> { ?uri a <#{type_uri.to_s}> } }"
      SparqlQuery.new(count_query).count
    end

    def resource_count
      self.types.map{|t| type_count(t.uri)}.sum
    end

    def example_resources
      return @example_resources if @example_resources

      resource_queries = self.types.map do |t|
        "{ SELECT DISTINCT ?uri WHERE { ?uri a <#{t.uri.to_s}> } LIMIT 1 }"
      end
      query =  "SELECT ?uri WHERE { GRAPH <#{self.data_graph_uri.to_s}> {"
      query << resource_queries.join(" UNION ")
      query << "}}"
      @example_resources = ExampleResource.find_by_sparql(query)
      @example_resources.each {|r| r.eager_load!}
      @example_resources
    end

    def ontologies
      return @ontologies if @ontologies

      query =  "SELECT DISTINCT ?uri WHERE {"
      query << "  GRAPH <#{self.data_graph_uri.to_s}> {?s ?p ?o}"
      query << "  { ?p <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> ?uri } UNION { ?o <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> ?uri }"
      query << "  ?uri a <http://www.w3.org/2002/07/owl#Ontology>."
      query << "}"
      @ontologies = Ontology.find_by_sparql(query)
    end

    def concept_schemes
      return @concept_schemes if @concept_schemes

      query =  "SELECT DISTINCT ?uri WHERE {"
      query << "  GRAPH <#{self.data_graph_uri.to_s}> {?s ?p ?o}"
      query << "  { ?p <http://www.w3.org/2004/02/skos/core#inScheme> ?uri } UNION { ?o <http://www.w3.org/2004/02/skos/core#inScheme> ?uri }"
      query << "  ?uri a <http://www.w3.org/2004/02/skos/core#ConceptScheme>"
      query << "}"
      @concept_schemes = ConceptScheme.find_by_sparql(query)
    end

    def theme_obj
      Theme.find(self.theme.to_s) rescue nil
    end

    module ClassMethods
      include PublishMyData::AllFeatures::ClassMethods

      # this is the graph that dataset metadata goes in.
      def metadata_graph_uri(slug)
        "#{data_graph_uri(slug)}/metadata"
      end

      # this is the dataset that the actual data will go in
      def data_graph_uri(slug)
        "http://#{PublishMyData.local_domain}/graph/#{slug}"
      end

      def uri_from_data_graph_uri(data_graph_uri)
        data_graph_uri.to_s.sub("/graph/", "/data/")
      end

      def uri_from_slug(slug)
        "http://#{PublishMyData.local_domain}/data/#{slug}"
      end

      # Criteria etc.

      def ordered_by_title
        all.where("?uri <#{RDF::DC.title}> ?title").order("?title")
      end

      def data_cubes
        find_by_sparql("
          SELECT DISTINCT ?uri WHERE {
            ?uri a <#{RDF::PMD_DS.Dataset}> .
            ?s <http://purl.org/linked-data/cube#dataSet> ?uri .
          }
        ")
      end

      def deprecation_last_query_str
        "
        SELECT ?uri where {
          # this bit is all the non-deprecated ones
          {
            SELECT * WHERE {
              ?uri a <http://publishmydata.com/def/dataset#Dataset> .
              ?uri <#{RDF::DC.title}> ?title . # select title so we can order
              MINUS {
                ?uri a <http://publishmydata.com/def/dataset#DeprecatedDataset>
              }
            }
            ORDER BY ?title
          }
          UNION
          # this bit is all the deprecated ones
          {
            SELECT * WHERE {
              ?uri a <http://publishmydata.com/def/dataset#DeprecatedDataset> .
              ?uri <#{RDF::DC.title}> ?title . # select title so we can order
            }
            ORDER BY ?title
          }
        }
        "
      end
    end
  end
end