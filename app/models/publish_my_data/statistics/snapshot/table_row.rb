require 'forwardable'

module PublishMyData
  module Statistics
    class Snapshot
      class TableRow
        extend Forwardable
        include Enumerable

        def initialize(attributes)
          @observation_source = attributes.fetch(:observation_source)
          @labeller           = attributes.fetch(:labeller)

          @row_uri  = attributes.fetch(:row_uri)
          @cells    = map_dataset_descriptions_to_cells(
            attributes.fetch(:dataset_descriptions)
          )
        end

        def_delegator :@cells, :each

        def values
          map(&:value)
        end

        def uri
          @row_uri
        end

        def label
          @labeller.label_for(@row_uri)
        end

        def to_h
          { row_uri: @row_uri, cells: @cells.map(&:to_h) }
        end

        private

        def map_dataset_descriptions_to_cells(descriptions)
          descriptions.map { |description|
            description.fetch(:cell_coordinates).map { |coords|
              TableCell.new(
                observation_source:   @observation_source,
                dataset_uri:          description.fetch(:dataset_uri),
                measure_property_uri: description.fetch(:measure_property_uri),
                row_uri:              @row_uri,
                cell_coordinates:     coords
              )
            }
          }.flatten
        end
      end
    end
  end
end