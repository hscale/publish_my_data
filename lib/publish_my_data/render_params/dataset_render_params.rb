module PublishMyData
  class DatasetRenderParams

    def initialize(resource)
      @resource = resource
      @dataset = resource.as_dataset
    end

    def render_params(opts={})
      @dataset.eager_load_object_triples!(:labels_only => true) # for the owner URI label

      {
        template: 'publish_my_data/datasets/show', locals: {dataset: @dataset}
      }
    end

  end
end