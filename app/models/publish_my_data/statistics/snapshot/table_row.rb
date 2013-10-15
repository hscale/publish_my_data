module PublishMyData
  module Statistics
    class Snapshot
      class TableRow
        def initialize(attributes)
          @observation_source = attributes.fetch(:observation_source)
          @labeller           = attributes.fetch(:labeller)

          @row_uri  = attributes.fetch(:row_uri)
          @cells    = map_dataset_descriptions_to_cells(
            attributes.fetch(:dataset_descriptions)
          )
        end

        def label
          @labeller.label_for(@row_uri)
        end

        def values
          @cells.map { |cell| cell.value(@observation_source) }
        end

        def to_h
          { row_uri: @row_uri, cells: @cells.map(&:to_h) }
        end

        private

        def map_dataset_descriptions_to_cells(descriptions)
          descriptions.map { |description|
            description.fetch(:cell_coordinates).map { |coords|
              # We'll need the observation source and labeller at some point
              TableCell.new(
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