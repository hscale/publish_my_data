module PublishMyData
  module Statistics
    class Snapshot
      class TableCell
        def initialize(description)
          @observation_source = description.fetch(:observation_source)

          @dataset_uri          = description.fetch(:dataset_uri)
          @measure_property_uri = description.fetch(:measure_property_uri)
          # Might be able to factor @row_uri out of the cells
          @row_uri              = description.fetch(:row_uri)
          @cell_coordinates     = description.fetch(:cell_coordinates)
        end

        def value
          @observation_source.observation_value(to_h)
        end

        def to_s
          value.to_s
        end

        # Note that this duplicates the logic in HeaderColumn and Fragment
        def fragment_code
          @dataset_uri.hash
        end

        def to_h
          {
            dataset_uri:          @dataset_uri,
            measure_property_uri: @measure_property_uri,
            row_uri:              @row_uri,
            cell_coordinates:     @cell_coordinates
          }
        end
      end
    end
  end
end