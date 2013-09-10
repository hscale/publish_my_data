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

      def to_param
        123
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