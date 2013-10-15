require 'uuidtools'

module PublishMyData
  module Statistics
    class Fragment
      attr_reader :id, :dataset_uri

      def initialize(attributes)
        @id                   = attributes.fetch(:id) { UUIDTools::UUID.random_create.to_s }
        @dataset_uri          = attributes.fetch(:dataset_uri)
        @measure_property_uri = attributes.fetch(:measure_property_uri)
        @dimensions           = attributes.fetch(:dimensions)
      end

      def to_h
        {
          id:                   @id,
          dataset_uri:          @dataset_uri,
          measure_property_uri: @measure_property_uri,
          dimensions:           @dimensions
        }
      end

      def inform_observation_source(observation_source)
        observation_source.dataset_detected(
          dataset_uri:          @dataset_uri,
          measure_property_uri: @measure_property_uri,
          dimensions:           @dimensions
        )
      end

      def inform_snapshot(snapshot)
        snapshot.dataset_detected(
          dataset_uri:          @dataset_uri,
          measure_property_uri: @measure_property_uri
        )

        each_dimension_bottom_up_with_level do |(dimension_uri, values), level|
          snapshot.dimension_detected(
            dimension_uri:  dimension_uri,
            column_width:   number_of_encompassed_dimension_values_at_level(level),
            column_uris:    values
          )
        end
      end

      def inform_labeller(labeller)
        labellable_resource_uris.each do |resource_uri|
          labeller.resource_detected(resource_uri)
        end
      end

      def number_of_encompassed_dimension_values_at_level(level)
        if number_of_dimensions == 0
          0 # Special case as the main algorithm starts Enumerable#reduce with 1
        else
          volume_of_selected_cube / volume_at_level(level)
        end
      end

      # TODO: Implement
      def measure_label
        "Measure label goes here"
      end

      def save
        true
      end

      # Only still public because of the show page
      def volume_of_selected_cube
        volume_at_level(bottom_level)
      end

      private

      # Candidate for the prize for "most specific enumeration method"
      def each_dimension_bottom_up_with_level(&block)
        # Watch out as there's no spec for the use of reverse here
        @dimensions.map.with_index.to_a.reverse.each(&block)
      end

      def dimension_value_pairs
        @dimensions.reduce([]) { |coords, (dimension_uri, dimension_values)|
          coords << dimension_values.map { |value| {dimension_uri => value} }
        }
      end

      def volume_at_level(level)
        @dimensions.keys[0..level].reduce(1) { |volume, dimension|
          volume * @dimensions[dimension].length
        }
      end

      def volume_at_level_above(level)
        if level == 0
          1
        else
          volume_at_level(level - 1)
        end
      end

      def bottom_level
        number_of_dimensions
      end

      def number_of_dimensions
        @dimensions.length
      end

      def labellable_resource_uris
        [
          @dataset_uri,
          @measure_property_uri
        ].concat(
          @dimensions.keys
        ).concat(
          @dimensions.values
        ).flatten
      end
    end
  end
end