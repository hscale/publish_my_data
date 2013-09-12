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

      def save
        true
      end
    end
  end
end