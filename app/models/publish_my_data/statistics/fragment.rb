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
            column_uris:    values * volume_at_level_above(level)
          )
        end
      end

      def values_for_row(options)
        # [].reduce(...) => nil below means we have to catch the empty case
        return [] if @dimensions.empty?

        # Yes, it works. Don't touch it.
        dimension_value_pairs.inject(:product).
          map { |maybe_already_flattened_product|
            if maybe_already_flattened_product.is_a?(Hash)
              maybe_already_flattened_product
            else
              maybe_already_flattened_product.flatten
            end
          }.
          map { |maybe_already_merged_product|
            if maybe_already_merged_product.is_a?(Hash)
              maybe_already_merged_product
            else
              maybe_already_merged_product.inject(:merge)
            end
          }.
          map { |cell_coordinates|
            # This will be much nicer when we switch to Ruby 2 and can use kwargs
            options.fetch(:observation_source).observation_value(
              dataset_uri:          @dataset_uri,
              measure_property_uri: @measure_property_uri,
              row_uri:              options.fetch(:row_uri),
              cell_coordinates:     cell_coordinates
            )
          }
      end

      def number_of_encompassed_dimension_values_at_level(level)
        if number_of_dimensions == 0
          # I couldn't figure out how to remove this special case.
          0
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
        @dimensions.keys[0..level].inject(1) { |volume, dimension|
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
    end
  end
end