module PublishMyData
  module CrumbHelper

    def crumb_list_item(link_text, link_path, css_class=nil)
      content_tag :li, :class => css_class do
        link_to link_text, link_path
      end
    end

    def data_home_crumb
      crumb_list_item("Home", "/")
    end

    def themes_crumb
      crumb_list_item("All Themes", themes_path)
    end

    def theme_crumb(theme, is_final=false)
      link_text = "Theme"
      link_text += ": <b>#{truncate(theme.label.to_s, length: 12)}</b>" unless is_final
      crumb_list_item(raw(link_text), theme_path(theme), "datasets")
    end

    def dataset_crumb(dataset, is_final=false)
      link_text = "Dataset"
      link_text += ": <b>#{truncate(dataset.title.to_s, length: 12)}</b>" unless is_final
      crumb_list_item(raw(link_text), dataset_path(dataset), "dataset")
    end

    def type_crumb(rdf_type_uri, dataset, is_final=false)
      if is_final
        link_text = "Resources of type"
        truncate_length = 20
      else
        link_text = "Type"
        truncate_length = 10
      end
      rdf_type = RdfType.find(rdf_type_uri) rescue nil
      type_label = rdf_type.label if rdf_type && rdf_type.label.present?
      link_text += ": <b>#{truncate(type_label.to_s, length: truncate_length)}</b>" if type_label
      crumb_list_item(raw(link_text), list_resources_path(:dataset => dataset, :type_uri => rdf_type_uri), "type")
    end

    def resource_crumb(text="Resource")
      crumb_list_item(text, "#", "resource")
    end

    def ontology_crumb(ontology, is_final=false)
      link_text = "Ontology"
      link_text += ": <b>#{truncate(ontology.label.to_s, length: 12)}</b>" unless is_final || ontology.label.blank?
      crumb_list_item(raw(link_text), resource_path_from_uri(ontology.uri), "docs")
    end

    def concept_scheme_crumb(concept_scheme, is_final=false)
      link_text = "Concept Scheme"
      link_text += ": <b>#{truncate(concept_scheme.label.to_s, length: 12)}</b>" unless is_final || concept_scheme.label.blank?
      crumb_list_item(raw(link_text), resource_path_from_uri(concept_scheme.uri), "docs")
    end

  end
end