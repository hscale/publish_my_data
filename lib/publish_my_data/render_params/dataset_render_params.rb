module PublishMyData
  class DatasetRenderParams

    def initialize(resource)
      @resource = resource
      @dataset = resource.as_dataset
    end

    def render_params(opts={})

      if opts[:is_html]
        @types = RdfType.where('?s a ?uri').graph(@dataset.data_graph_uri).resources
        @dataset.eager_load_object_triples!(:labels_only => true) # for the owner URI label
        @type_resource_counts = {}
        @resources_count = 0
        @types.each do |t|
          count_query = "SELECT ?uri WHERE { GRAPH <#{@dataset.data_graph_uri.to_s}> { ?uri a <#{t.uri.to_s}> } }"
          @type_resource_counts[t.uri.to_s] = SparqlQuery.new(count_query).count
          @resources_count += @type_resource_counts[t.uri.to_s]
        end
      end

      {
        template: 'publish_my_data/datasets/show', locals: {
          dataset: @dataset,
          types: @types,
          type_resource_counts: @type_resource_counts,
          resources_count: @resources_count
        }
      }
    end

  end
end