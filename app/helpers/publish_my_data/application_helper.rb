module PublishMyData
  module ApplicationHelper

    def bodyclass(c)
      @bodyclass = c;
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

  end
end
