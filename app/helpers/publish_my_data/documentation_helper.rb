module PublishMyData
  module DocumentationHelper

    def documentation_section(title, &block)
      content_tag :section do
        concat content_tag :h2, title
        concat capture &block
      end
    end

    def documentation_subsection(title, &block)
      content_tag :div, class:"subsection", id:title.parameterize do
        concat content_tag :h3, title
        concat capture &block
      end
    end

    def documentation_subsubsection(title, &block)
      content_tag :div, class:"subsubsection", id:title.parameterize do
        concat content_tag :h4, title
        concat capture &block
      end
    end

    def codeblock(language, &block)
      content_tag :code, class:"block #{language}" do
        capture &block
      end
    end

    def codeblock_pre(language, &block)
      content_tag :code, class:"block #{language} pre" do
        capture &block
      end
    end

  end
end