module PublishMyData
  module SelectorsHelper
    def dom_class_for_header_column(header_column)
      case header_column.type
      when :measure_property
        "measure"
      else
        "fragment-TBD"
      end
    end

    def dom_class_for_row_value(row_value)
      "fragment-TBD"
    end

    def dom_class_for_fragment(fragment)
      "fragment-TBD"
    end
  end
end
