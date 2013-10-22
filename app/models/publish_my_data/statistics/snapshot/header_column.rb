module PublishMyData
  module Statistics
    class Snapshot
      class HeaderColumn
        attr_reader :uri, :label, :width, :type

        def initialize(attributes = {})
          @dataset_uri  = attributes.fetch(:dataset_uri)
          @uri          = attributes[:uri]
          @label        = attributes[:label]
          @width        = attributes.fetch(:width, 1)
          @type         = attributes.fetch(:type, :blank)
        end

        def read_label(labeller)
          # Maybe we should make labelling blank columns explicit
          @label = labeller.label_for(@uri) if @uri
        end

        # Note that this duplicates the logic in TableCell and Fragment
        def fragment_code
          @dataset_uri.hash
        end
      end
    end
  end
end