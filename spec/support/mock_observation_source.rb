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

        # TODO next:
        # probably wrong...
        # coordinates.inject(row_data) { |remaining_data, coord|
        #   remaining_data.fetch
        # }

        key = coordinates.keys.first
        row_data.fetch(key).fetch(coordinates[key])
      end
    end
  end
end