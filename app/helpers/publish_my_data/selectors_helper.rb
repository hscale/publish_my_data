module PublishMyData
  module SelectorsHelper
    def dom_class_for_fragment(header_column)
      "fragment-#{header_column.fragment_code}"
    end
  end
end
