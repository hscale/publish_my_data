module PublishMyData
  module ApplicationHelper
    def page_title(title=nil)
      content_for :page_title do
        "| #{title}"
      end
    end

    def page_description(description)
      content_for :page_description do
        content_tag(:meta, '', name: 'description', content: description)
      end
    end

    def link_to_home
      link_to 'Home', '/'
    end

    def pagination_required?(resources, pagination_params)
      (resources.total_count > pagination_params.per_page)
    end

    def top_section(h1=nil, h2=nil, h1_label=nil, h2_label=nil, &block)
      content_tag(:section, id: 'top') do
        main_content = ""
        main_content << content_tag(:div, class: 'row container') do
          content_tag(:div, class: 'sixteen columns') do
            top_row_content = ""
            top_row_content << content_tag(:h3, h1_label) if h1_label
            top_row_content << content_tag(:h1, h1) if h1
            top_row_content << content_tag(:h3, h2_label) if h2_label
            top_row_content << content_tag(:h2, h2, class: "hardwrap click-to-select") if h2
            top_row_content.html_safe
          end
        end
        main_content << capture(&block) if block && capture(&block)
        main_content.html_safe
      end
    end

    def bottom_formats_section(message=nil, *links)
      content_tag(:section, id: 'bottom') do
        content_tag(:div, class: 'row container') do
          content_tag(:div, class: 'sixteen columns') do
            content_tag(:ul) do
              list = ""
              list << content_tag(:li) do
                if message
                  "This <strong>#{message}</strong> is available as".html_safe
                else
                  "This <strong>page</strong> is available as".html_safe
                end
              end
              #always show HTML (doens't link to anywhere)
              list << content_tag(:li) do
                content_tag :a, "HTML", class: "selected"
              end

              list << links.reduce('') { |c, link|
                c << content_tag(:li, link)
              }.html_safe

              list.html_safe
            end
          end
        end
      end
    end
  end
end
