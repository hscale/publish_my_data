module PublishMyData
  module Statistics
    class MockObservationSource
      def initialize(attributes)
        # Note that while we store this, we currently don't support looking up values by
        # measure property, as PMD currently only supports one measure per observation.
        # This isn't a very clear way of doing this - see the comment in #observation_value.
        @measure_property_uris = attributes.fetch(:measure_property_uris)
        @observation_data = attributes.fetch(:observation_data)
      end

      # Returns nil if you don't pass a known measure_property_uri in the description
      def observation_value(description)
        dataset_uri           = description.fetch(:dataset_uri)
        measure_property_uri  = description.fetch(:measure_property_uri)
        row_type_uri          = description.fetch(:row_type_uri)
        row_uri               = description.fetch(:row_uri)
        cell_coordinates      = description.fetch(:cell_coordinates)

        # Fake "mismatched measure properties" - see the comment above #measure_property_uris
        return unless @measure_property_uris.include?(measure_property_uri)

        row_data = @observation_data.
          fetch(dataset_uri).
          fetch(row_type_uri).
          fetch(row_uri)

        cell_coordinates.inject(row_data) { |remaining_data, (dimension, dimension_value)|
          remaining_data.fetch(dimension).fetch(dimension_value)
        }
      end
    end
  end
end