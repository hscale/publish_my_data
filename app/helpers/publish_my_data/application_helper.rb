module PublishMyData
  module ApplicationHelper

    def inside_layout(layout, &block)
      layout = "layouts/#{layout}" unless layout =~ %r[\Alayouts/]
      content_for :publish_my_data_content, capture(&block)
      render template: layout
    end

    def set_pmd_page_class(c)
      @pmd_page_class = c;
    end

    def set_page_title(title=nil)
      content_for :page_title do
        "| #{title}"
      end
    end

    def appname
      PublishMyData.application_name
    end

    def page_description(description)
      content_for :page_description do
        # should be content_tag(:meta, '', name: 'description', content:description)
        # but content tag doesn't generate valid html accoring to the w3c validator :(
        # content_tag(:meta, '', name: 'description', content: "hello world") => <meta content="hello world" name="description"></meta>
        if (description)
          raw "<meta name='description' content='#{description}'>"
        end
      end
    end

    def pagination_required?(resources, pagination_params)
      (resources.total_count > pagination_params.per_page)
    end

    def human_readable_name(resource)
      name = resource.human_readable_name
      if resource.human_readable_name_is_uri?
        name = annotate_as_uri(name)
      end
      return name
    end

    def annotate_as_uri(s)
      raw("<span class='pmd_inline_uri'>#{s}</span>")
    end

  end
end
