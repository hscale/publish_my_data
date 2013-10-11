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

      def initialize
        @rows               = [ ]
        @current_row_index  = 0
        @completed_width    = 0
      end

      def dataset_detected(description)
        # We get these, I assume we will need it at some point...
        # dataset_uri           = description.fetch(:dataset_uri),
        # measure_property_uri  = description.fetch(:measure_property_uri)

        move_to_first_row
        remember_completed_width
      end

      # An idempotent event handler written initially to lazily pad the end of
      # rows when we're asked to give back the labelled rows, but I've left it
      # public as it it's symettric with #dataset_detected
      def dataset_completed
        return if @rows.empty?
        remember_completed_width

        @rows.each.with_index do |row, index|
          pad_row_to_end(index)
        end
      end

      # Be sure to call this with the lowest dimension first
      def dimension_detected(description)
        ensure_row
        pad_current_row_to_end

        # We get the first one, I assume we will need it at some point...
        # dimension_uri = description.fetch(:dimension_uri)
        column_width  = description.fetch(:column_width)
        column_uris   = description.fetch(:column_uris)

        column_uris.each do |column_uri|
          current_row << HeaderColumn.new(uri: column_uri, width: column_width)
        end

        move_to_next_row
      end

      def header_rows(labeller = Selector::Labeller.new)
        dataset_completed
        label_columns(labeller)
        @rows.reverse
      end

      private

      def ensure_row
        if current_row.nil?
          start_new_row
          pad_row_from_start
        end
      end

      def start_new_row
        @rows << []
      end

      def pad_row_from_start
        if current_row.empty?
          @completed_width.times do
            current_row << HeaderColumn.new
          end
        end
      end

      def row_width(index)
        return if @rows.empty?
        @rows[index].map(&:width).reduce(0, :+)
      end

      def pad_current_row_to_end
        pad_row_to_end(@current_row_index)
      end

      def pad_row_to_end(index)
        width_of_void = @completed_width - row_width(index)

        width_of_void.times do
          @rows[index] << HeaderColumn.new
        end
      end

      def current_row
        @rows[@current_row_index]
      end

      def move_to_first_row
        @current_row_index = 0
        ensure_row
      end

      def remember_completed_width
        @completed_width = row_width(0)
      end

      def move_to_next_row
        @current_row_index += 1
      end

      def label_columns(labeller)
        @rows.each do |row|
          row.each do |column|
            column.read_label(labeller)
          end
        end
      end
    end
  end
end