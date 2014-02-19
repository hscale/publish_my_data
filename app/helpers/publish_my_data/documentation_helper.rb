module PublishMyData
  module DocumentationHelper

    def documentation_section(index, title, &block)
      content_tag :section do
        concat content_tag :h2, "#{index} - #{title}"
        concat capture &block
      end
    end

    def documentation_subsection(index, title, &block)
      content_tag :div, class:"subsection", id:title.parameterize do
        concat content_tag :h3, raw("#{index} - #{content_tag(:strong, title)}")
        concat capture &block
      end
    end

    def codeblock(&block)
      content_tag :code, class:"block" do
        capture &block
      end
    end

  end
end