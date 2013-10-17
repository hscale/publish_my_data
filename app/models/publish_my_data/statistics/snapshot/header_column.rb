module PublishMyData
  module Statistics
    class Snapshot
      class HeaderColumn
        attr_reader :uri, :label, :width, :type

        def initialize(attributes = {})
          @uri    = attributes[:uri]
          @label  = attributes[:label]
          @width  = attributes.fetch(:width, 1)
          @type   = attributes.fetch(:type, nil) # Maybe raise an error?
        end

        def read_label(labeller)
          # Maybe we should make labelling blank columns explicit
          @label = labeller.label_for(@uri) if @uri
        end
      end
    end
  end
end