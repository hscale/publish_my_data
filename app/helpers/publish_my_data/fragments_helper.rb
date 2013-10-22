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

    def group_datasets_by_theme(datasets, themes)
      grouped_datasets = datasets.group_by do |dataset|
        theme = themes.find {|t| t.uri == dataset.theme}
        theme.label
      end

      grouped_datasets.keys.each do |label|
        grouped_datasets[label] = grouped_datasets[label].map{ |dataset| [dataset.title, dataset.uri.to_s] }
      end

      grouped_datasets
    end
  end
end
