module PublishMyData
  module Statistics
    class MockObservationSource
      def initialize(observation_data)
        @observation_data = observation_data
      end

      def observation_value(dataset_uri, row_type_uri, row_uri, coordinates)
        row_data = @observation_data.
          fetch(dataset_uri).
          fetch(row_type_uri).
          fetch(row_uri)

        coordinates.inject(row_data) { |remaining_data, (dimension, dimension_value)|
          remaining_data.fetch(dimension).fetch(dimension_value)
        }
      end
    end
  end
end