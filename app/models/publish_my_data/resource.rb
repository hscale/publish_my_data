module PublishMyData
  class Resource

    include Tripod::Resource

    field :label, RDF::RDFS.label

    # this calls render_params on the right type of RenderParams object.
    # (strategy pattern-ish).
    def render_params(request)
      render_params_class.new(self).render_params(pagination_params: PaginationParams.from_request(request))
    end

    def as_theme
      # Don't worry that this looks like it'll do an extra lookup.
      # In production, it'll be cached from a moment ago anyway!
      Theme.find(self.uri)
    end

    def is_theme?
      read_predicate(RDF.type).include?(Theme.theme_type)
    end

    # Is this resource in the host domain?
    def local?
      uri.starts_with?("http://" + PublishMyData.local_domain)
    end

    def self.uri_from_host_and_doc_path(host, doc_path, format="")
      'http://' + host + '/id/' + doc_path.split('?')[0].sub(/\.#{format}$/,'')
    end

    private

    def render_params_class
      if self.is_theme?
        ThemeRenderParams
      else
        ResourceRenderParams
      end
    end
  end

end
