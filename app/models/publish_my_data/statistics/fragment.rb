module PublishMyData
  module Statistics
    class Fragment
      attr_reader :selector, :dataset

      def initialize(dimensions = [ ])
        @dimensions = dimensions
      end

      def number_of_dimensions
        @dimensions.length
      end

      def dimension_value_labels
        @dimensions.map { |dimension|
          dimension.fetch(:dimension_values).map { |dimension_value|
            dimension_value.fetch(:dimension_value_label)
          }
        }
      end

      def number_of_dimensions
        @dimensions.length
      end

      def number_of_encompassed_dimension_values_at_level(level)
        if number_of_dimensions == 0
          # I couldn't figure out how to remove this special case
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