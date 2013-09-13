module PublishMyData
  module ResourcesHelper

    # uses eager loaded data to get the uri or label for a term
    def resource_uri_or_label(resource, term)

      if term.try(:uri?) # if it's a RDF::URI it will respond to uri? with true
        res = resource.get_related_resource(term, PublishMyData::Resource)
        if res
          link_to((res.label || res.uri.to_s), resource_path_from_uri(res.uri))
        else
          link_to term.to_s, resource_path_from_uri(term)
        end
      else
        term.to_s
      end
    end

    def resource_path_from_uri(uri)
      resource = Resource.new(uri)
      if resource.in_domain?(request.host)
        uri.to_s
      else
        publish_my_data.show_resource_path(:uri => uri.to_s)
      end
    end

    def resources_list_table_title

      str = "<strong> #{pluralize @resources.total_count, 'resource'}</strong>"
      if @type_filter
        str += " of type "
        if @type
          str += link_to @type.label || @type.uri, resource_path_from_uri(@type.uri)
        else
          str += link_to @type_filter, resource_path_from_uri(@type_filter)
        end
      end

      if @dataset_filter
        str += " in dataset "
        if @dataset
          str += link_to @dataset.title, @dataset
        else
          str += link_to @dataset_filter, resource_path_from_uri(@dataset_filter)
        end
      end

      str.html_safe
    end
  end
end
