module PublishMyData
  module Statistics
    class Snapshot
      class HeaderColumn
        attr_reader :label
        attr_reader :width

        def initialize(attributes = {})
          @uri    = attributes.fetch(:uri, nil)
          @width  = attributes.fetch(:width, 1)

          @label  = nil
        end

        def read_label(labeller)
          # Maybe we should make labelling blank columns explicit
          @label = labeller.label_for(@uri) if @uri
        end
      end
    end
  end
end