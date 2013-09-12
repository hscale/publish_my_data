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
        # This won't handle mismatched sizes yet
        # Also hack the null case for now
        number_of_rows = @fragments.first.number_of_dimensions rescue 0

        header_rows = [ ]

        number_of_rows.times do |row_index|
          header_rows[row_index] = [ ]

          @fragments.each do |fragment|
            header_rows[row_index].concat(
              fragment.dimension_value_labels[row_index]
            )
          end
        end

        header_rows
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