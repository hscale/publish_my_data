module PublishMyData
  module Statistics
    class Snapshot
      # A HeaderRowSet is an object which can construct a set of table header
      # rows from vertical slices of column headers of different widths and
      # heights, and handles any padding necessary to ensure they line up with
      # the table body data to be displayed below.
      class HeaderRowSet
        include Enumerable

        def initialize
          @rows = [ ]

          @current_row_index = 0
          @completed_width = 0
        end

        def concat_rows(rows)
          move_to_first_row
          rows.each do |row|
            ensure_header_row
            pad_current_header_row_to_end
            current_row.concat(row)
            move_to_next_header_row
          end
          remember_completed_header_width
          pad_header_rows_to_completed_width
        end

        def move_to_first_row
          @current_row_index = 0
          ensure_header_row
        end

        # TODO: kill me
        def pad_header_rows_to_completed_width
          @rows.each.with_index do |row, index|
            pad_row_to_end(index)
          end
        end

        def label_columns(labeller)
          @rows.each do |row|
            row.each do |column|
              column.read_label(labeller)
            end
          end
        end

        def each(&block)
          @rows.each(&block)
        end

        def to_a
          @rows.reverse
        end

        private

        def ensure_header_row
          if current_row.nil?
            start_new_row
            pad_row_from_start
          end
        end

        def current_row
          @rows[@current_row_index]
        end

        def start_new_row
          @rows << [ ]
        end

        def pad_row_from_start
          if current_row.empty?
            @completed_width.times do
              current_row << HeaderColumn.new
            end
          end
        end

        def pad_current_header_row_to_end
          pad_row_to_end(@current_row_index)
        end

        def pad_row_to_end(index)
          width_of_void = @completed_width - row_width(index)

          width_of_void.times do
            @rows[index] << HeaderColumn.new
          end
        end

        def remember_completed_header_width
          @completed_width = row_width(0)
        end

        def row_width(index)
          return if @rows.empty?
          @rows[index].map(&:width).reduce(0, :+)
        end

        def move_to_next_header_row
          @current_row_index += 1
        end
      end
    end
  end
end