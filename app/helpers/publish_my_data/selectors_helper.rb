module PublishMyData
  module SelectorsHelper
    def header_depth(selector)
      selector.max_number_of_fragment_dimensions
    end

    def fragment_headings_at_depth(selector, fragment, depth)
      ['foo', 'bar', 'baz']
    end

    def heading_span(selector, fragment, depth)
      1
    end

    def column_values(fragment, row)
      [1, 2, 3]
    end

    def total_columns(selector)
      3
    end

    def first_row?(selector, row)
      (selector.rows.first.uri == row.uri)
    end
  end
end
