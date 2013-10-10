require 'uuidtools'

module PublishMyData
  module Statistics
    class Fragment
      attr_reader :id, :dataset_uri

      def initialize(attributes)
        @id                   = attributes.fetch(:id) { UUIDTools::UUID.random_create }
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

      def to_observation_query_options
        {
          dataset_uri:          @dataset_uri,
          measure_property_uri: @measure_property_uri,
          dimensions:           @dimensions
        }
      end

      # We want to use this structure everywhere
      # TODO: delete me
      def simplified_dimensions
        @dimensions.reduce({}) { |dimensions, dimension|
          dimensions.merge!(
            dimension.fetch(:dimension_uri) => dimension.fetch(:dimension_values)
          )
        }
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

      def number_of_dimensions
        @dimensions.keys.length
      end

      def dimension_value_labels
        @dimensions.map.with_index { |(_dimension, values), level|
          values * volume_at_level_above(level)
        }
      end

      def number_of_dimensions
        @dimensions.length
      end

      def number_of_encompassed_dimension_values_at_level(level)
        if number_of_dimensions == 0
          # I couldn't figure out how to remove this special case.
          #
          0
        else
          volume_of_selected_cube / volume_at_level(level)
        end
      end

      def volume_of_selected_cube
        volume_at_level(bottom_level)
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

      def save
        true
      end

      private

      def dimension_value_pairs
        @dimensions.reduce([]) { |coords, (dimension_uri, dimension_values)|
          coords << dimension_values.map { |value| {dimension_uri => value} }
        }
      end

      def bottom_level
        number_of_dimensions
      end
    end
  end
end