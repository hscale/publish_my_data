module PublishMyData
  module Statistics
    class Selector
      class << self
        def create
          new
        end

        def find(id)
          create
        end
      end

      attr_reader :fragments

      def initialize
        @fragments = [ ]
      end

      def to_param
        123
      end

      def header_rows
        [
          @fragments.inject([ ]) { |row, fragment|
            row.concat(fragment.dimension_value_labels)
            row
          }
        ]
      end

      def build_fragment(dimensions)
        @fragments << Fragment.new(dimensions)
      end

      def rows
        Resource.find_by_sparql("
          SELECT distinct ?uri
          WHERE {
            ?uri a <http://statistics.data.gov.uk/def/statistical-geography>.
          }
          LIMIT 20
        ")
      end
    end
  end
end