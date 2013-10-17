module PublishMyData
  module Statistics
    # A Snapshot is an object that can display a Selector at a particular
    # point in time. It is constructed empty, then listens to #dataset_detected,
    # #dimension_detected and #dataset_completed events as the Selector walks
    # the Fragments. It then constructs header rows with the appropriate
    # nesting of dimensions, and table rows with the data cube coordinates for
    # each observation.
    #
    # Having written this algorithm twice, I now suspect the easiest way to do
    # it might be a sparse data structure (like a spreadsheet). The padding
    # algorithm (now in HeaderRowSet) is the hardest bit, if that was
    # encapsulated maybe the rest of this would simplify a lot. - Ash
    class Snapshot
      def initialize(dependencies)
        @observation_source = dependencies.fetch(:observation_source)
        @labeller           = dependencies.fetch(:labeller)

        # Derived structure
        @header_rows = HeaderRowSet.new
        @datasets       = [ ]
        @body_row_uris  = [ ]

        # Transient state as we listen for #dataset_detected and #dimension_detected
        # (Arguably we should split this class in two so we can discard the transient
        # builder state at the end)
        @current_dataset_header_rows      = [ ]
        @current_dataset_cell_coordinates = nil
      end

      def dataset_detected(description)
        dataset_completed

        dataset_uri           = description.fetch(:dataset_uri)
        measure_property_uri  = description.fetch(:measure_property_uri)

        create_new_dataset_structure(
          dataset_uri: dataset_uri, measure_property_uri: measure_property_uri
        )
      end

      # An idempotent event handler written initially to lazily pad the end of
      # rows when we're asked to give back the labelled rows, but I've left it
      # public as it it's symmetric with #dataset_detected
      def dataset_completed
        return if no_dataset_in_progress?
        # TODO (maybe)
        # add_dataset_level_headers
        concat_current_dataset_onto_header
        clear_dataset_in_progress
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

      def header_rows
        dataset_completed
        @header_rows.label_columns(@labeller)
        @header_rows.to_a
      end

      def table_rows
        @body_row_uris.map { |row_uri|
          TableRow.new(
            observation_source:   @observation_source,
            row_uri:              row_uri,
            labeller:             @labeller,
            dataset_descriptions: @datasets
          )
        }
      end

      def render(output_builder)
        output_builder.document_header_started
        output_builder.document_header_finished
        header_rows.each do |header_row|
          output_builder.header_row(header_row)
        end
        table_rows.each do |table_row|
          output_builder.table_row(
            row_uri:    table_row.uri,
            row_label:  table_row.label,
            values:     table_row.values
          )
        end
      end

      private

      def no_dataset_in_progress?
        @current_dataset_header_rows.empty?
      end

      def clear_dataset_in_progress
        @current_dataset_header_rows = [ ]
      end

      def concat_current_dataset_onto_header
        @header_rows.concat_rows(@current_dataset_header_rows)
      end

      def update_header_based_on_dimension(dimension_uri, column_width, column_uris)
        new_row = column_uris.map { |column_uri|
          HeaderColumn.new(uri: column_uri, width: column_width, type: :dimension_value)
        }
        number_of_columns_in_new_dimension = column_uris.length
        @current_dataset_header_rows.each do |row|
          row.replace(row * number_of_columns_in_new_dimension)
        end
        @current_dataset_header_rows << new_row
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
        @current_dataset_cell_coordinates =
          description[:cell_coordinates] = [ ]
      end
    end
  end
end