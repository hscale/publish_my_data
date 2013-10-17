module PublishMyData
  module Statistics
    class Snapshot
      class TableCell
        def initialize(description)
          @dataset_uri          = description.fetch(:dataset_uri)
          @measure_property_uri = description.fetch(:measure_property_uri)
          # Might be able to factor @row_uri out of the cells
          @row_uri              = description.fetch(:row_uri)
          @cell_coordinates     = description.fetch(:cell_coordinates)
        end

        # It might be convenient to implement #to_s as an alias for
        # value, but if so we'd need to pass the observation source in
        # via the constructor
        def value(observation_source)
          observation_source.observation_value(to_h)
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