module PublishMyData
  module ResourcesHelper

    # uses eager loaded data to get the uri or label for a term
    def resource_uri_or_label(resource, term)

      if term.uri?
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
  end
end
