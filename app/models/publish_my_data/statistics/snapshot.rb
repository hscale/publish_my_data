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
        # Derived structure
        @header_rows    = [ ]
        @datasets       = [ ]
        @body_row_uris  = [ ]

        # Transient builder state
        @current_row_index                = 0
        @completed_width                  = 0
        @current_dataset_cell_coordinates = nil
      end

      def dataset_detected(description)
        dataset_uri           = description.fetch(:dataset_uri)
        measure_property_uri  = description.fetch(:measure_property_uri)

        move_to_first_row
        remember_completed_width
        # We reconstruct the hash that's passed in to enforce the keys
        # and allow us to mutate it internally
        create_new_dataset_structure(
          dataset_uri: dataset_uri, measure_property_uri: measure_property_uri
        )
      end

      # An idempotent event handler written initially to lazily pad the end of
      # rows when we're asked to give back the labelled rows, but I've left it
      # public as it it's symmetric with #dataset_detected
      def dataset_completed
        return if @header_rows.empty?
        remember_completed_width

        @header_rows.each.with_index do |row, index|
          pad_row_to_end(index)
        end
      end

      # Be sure to call this with the lowest dimension first
      def dimension_detected(description)
        dimension_uri = description.fetch(:dimension_uri)
        column_width  = description.fetch(:column_width)
        column_uris   = description.fetch(:column_uris)

        update_header_based_on_dimension(dimension_uri, column_width, column_uris)
        update_body_based_on_dimension(dimension_uri, column_width, column_uris)
      end

      def row_uris_detected(row_uris)
        @body_row_uris.concat(row_uris)
      end

      def header_rows(labeller)
        dataset_completed
        label_columns(labeller)
        @header_rows.reverse
      end

      def table_rows(observation_source, labeller)
        @body_row_uris.map { |row_uri|
          TableRow.new(
            observation_source:   observation_source,
            row_uri:              row_uri,
            labeller:             labeller,
            dataset_descriptions: @datasets
          )
        }
      end

      private

      def update_header_based_on_dimension(dimension_uri, column_width, column_uris)
        ensure_row
        pad_current_row_to_end

        column_uris.each do |column_uri|
          current_row << HeaderColumn.new(uri: column_uri, width: column_width)
        end

        move_to_next_row
      end

      def update_body_based_on_dimension(dimension_uri, column_width, column_uris)
        new_dimension = column_uris.map { |uri| {dimension_uri => uri} }

        new_values =
          if @current_dataset_cell_coordinates.empty?
            new_dimension
          else
            new_dimension.product(@current_dataset_cell_coordinates).
              map { |product|
                product.inject({}, :merge)
              }
          end

        @current_dataset_cell_coordinates.replace(new_values)
      end

      def create_new_dataset_structure(description)
        @datasets << description
        @current_dataset_cell_coordinates = [ ]
        description[:cell_coordinates] = @current_dataset_cell_coordinates
      end

      def ensure_row
        if current_row.nil?
          start_new_row
          pad_row_from_start
        end
      end

      def start_new_row
        @header_rows << []
      end

      def pad_row_from_start
        if current_row.empty?
          @completed_width.times do
            current_row << HeaderColumn.new
          end
        end
      end

      def row_width(index)
        return if @header_rows.empty?
        @header_rows[index].map(&:width).reduce(0, :+)
      end

      def pad_current_row_to_end
        pad_row_to_end(@current_row_index)
      end

      def pad_row_to_end(index)
        width_of_void = @completed_width - row_width(index)

        width_of_void.times do
          @header_rows[index] << HeaderColumn.new
        end
      end

      def current_row
        @header_rows[@current_row_index]
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
        @header_rows.each do |row|
          row.each do |column|
            column.read_label(labeller)
          end
        end
      end
    end
  end
end