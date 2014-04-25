module ApplicationHelper

  def example_subnav_box
    {
      title: "Example Subnav Box",
      css_class: "pmd_nav_sub_api",
      target: publish_my_data.api_docs_path,
      highlight: "example_subnav_box",
      items: [
        {
          title: "Example menu item",
          target: '/example-item',
          highlight: "example_item_label"
        }
      ]
    }
  end

end
