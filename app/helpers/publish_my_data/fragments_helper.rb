module PublishMyData
  module FragmentsHelper
    def dom_id_for_dimension_value(dimension_value, prefix=nil)
      uri_string = dimension_value[:label].downcase.gsub(' ', '-')
      prefix.blank? ? uri_string : "#{prefix}-#{uri_string}"
    end

    def column_count(dimensions)
      count = 1
      dimensions.each do |dimension|
        count = count * dimension.values.size
      end
      count
    end
  end
end
