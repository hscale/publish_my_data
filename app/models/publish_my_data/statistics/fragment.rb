module PublishMyData
  module Statistics
    class Fragment
      attr_reader :selector, :dataset

      # def initialize(selector, dataset, dimensions = nil)
      #   @dimensions = [
      #     {
      #       dimension_uri: "http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/ethnicity",
      #       dimension_values: [
      #         "http://opendatacommunities.org/def/concept/general-concepts/ethnicity/asianOrAsianBritish",
      #         "http://opendatacommunities.org/def/concept/general-concepts/ethnicity/blackOrBlackBritish"
      #       ]
      #     }
      #   ]
      # end

      def initialize(dimensions = [ ])
        @dimensions = dimensions
      end

      def dimension_value_labels
        # Restrict to the first while we hack a one-line table together,
        # then hack an empty array if we got nothing (ugh)
        @dimensions.map { |dimension|
          dimension.fetch(:dimension_values).map { |dimension_value|
            dimension_value.fetch(:dimension_value_label)
          }
        }.first || [ ]
      end

      def save
        true
      end
    end
  end
end