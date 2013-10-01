module PublishMyData
  module Statistics
    class Fragment
      attr_reader :selector, :dataset

      def initialize(attributes)
        @dataset_uri = attributes.fetch(:dataset_uri) # Currently unused
        @dimensions = attributes.fetch(:dimensions)
      end

      def to_h
        {
          dataset_uri: @dataset_uri,
          dimensions: @dimensions
        }
      end

      def values_for_row(row_type_uri, row_uri, observation_source)
        return [] if @dimensions.empty?

        # One-to-many refactoring in progress...
        dimension = @dimensions.first
        dimension_value = dimension.fetch(:dimension_uri)
        row_coordinates =
          dimension.fetch(:dimension_values).inject([]) { |coords, value|
            coords << { dimension_value => value }
          }

        row_coordinates.map { |cell_coordinates|
          observation_source.observation_value(
            @dataset_uri, row_type_uri, row_uri, cell_coordinates
          )
        }
      end

      def number_of_dimensions
        @dimensions.length
      end

      def dimension_value_labels
        @dimensions.map.with_index { |dimension, level|
          dimension.fetch(:dimension_values).map { |dimension_value|
            # dimension_value.fetch(:dimension_value_label)
            # TEMP HACK:
            dimension_value
          } * volume_at_level_above(level)
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
        @dimensions[0..level].inject(1) { |volume, dimension|
          volume * dimension.fetch(:dimension_values).length
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

      def bottom_level
        number_of_dimensions
      end
    end
  end
end