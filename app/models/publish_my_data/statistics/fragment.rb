module PublishMyData
  module Statistics
    class Fragment
      attr_reader :selector, :dataset

      def initialize(selector, dataset, dimensions = nil)
        @dimensions = [
          {
            dimension_uri: "http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/ethnicity",
            dimension_values: [
              "http://opendatacommunities.org/def/concept/general-concepts/ethnicity/asianOrAsianBritish",
              "http://opendatacommunities.org/def/concept/general-concepts/ethnicity/blackOrBlackBritish"
            ]
          }
        ]
      end

      def save
        true
      end
    end
  end
end