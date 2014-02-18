module PublishMyData
  module SubnavigationHelper

    def submenu_link text, url, highlight_when
      unless (highlight_when.nil?) 
        css_class = highlight_when == @highlight_in_menu ? "pmd_selected" : ""
      end
      link_to text, url, class: css_class
    end

    def standard_menu_catalogue
      {
        title: "Catalogue",
        css_class: "pmd_nav_sub_catalogue",
        target: publish_my_data.datasets_path,
        highlight: "catalogue",
        items: [
          {
            title: "Datasets by theme",
            target: '/themes',
            highlight: "browse"
          }
        ]
      }
    end

    def standard_menu_tools
      {
        title: "Tools",
        css_class: "pmd_nav_sub_tools",
        target: publish_my_data.tools_path,
        highlight: "tools",
        items: [
          {
            title: "SPARQL endpoint",
            target: publish_my_data.sparql_endpoint_path,
            highlight: "endpoint"
          }
        ]
      }
    end

    def standard_menu_docs
      {
        title: "Documentation",
        css_class: "pmd_nav_sub_api",
        target: publish_my_data.api_docs_path,
        highlight: "documentation",
        items: []
      }
    end

    def standard_menu_pmd
      {
        title: "PublishMyData",
        css_class: "pmd_nav_sub_pmd",
        target: publish_my_data.about_pmd_path,
        highlight: "about pmd",
        items: [
          {
            title: "Source (Github)",
            target: "http://github.com/Swirrl/publish_my_data",
            highlight: nil
          },
          {
            title: "Swirrl.com",
            target: "http://swirrl.com",
            highlight: nil
          }
        ]
      }
    end

  end
end