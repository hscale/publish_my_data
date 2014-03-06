module PublishMyData
  module StripesHelper

    # returns the complement (by key) of hash_to_exclude in hash
    # eg:
    #     h = { "a" => 100, "b" => 400, "c" => 300  }
    #     x = { "a" => 100, "b" => 40 }
    #     puts exclude_keys(h,x))
    #     $ {"c" => 300}
    def exclude_keys(hash, hash_to_exclude)
      unless (hash.nil?)
        unless (hash_to_exclude.nil?)
          hash.delete_if {|k,v| hash_to_exclude.include? k}
        else
            return hash
        end
      else
        return nil
      end
    end

    def to_css_name(str)
      # convention for id and class names is underscore_case
      str.downcase.split(" ").join("_")
    end

    def badge(s)
      content_tag :div, :class => "pmd_badge badge_#{to_css_name(s)}" do
        s
      end
    end

    def row &block
      capture_haml do
        haml_tag "div", :class => 'pmd_wrapper' do
          haml_tag "div", :class => 'pmd_row' do
            yield
          end
        end
      end
    end

    def fullwidth &block
      row do
        haml_tag "div", :class => 'pmd_box_full' do
          yield
        end
      end
    end

    def page_kind(kind_str)
      @page_kind = kind_str
    end

    def highlight_in_menu(str)
      @highlight_in_menu = str.downcase
    end

    def title_uri(uri)
      html_str = label 'URI'
      html_str += content_tag :h2, :class => "code click_to_select" do
        uri.to_s
      end
      html_str
    end


    def label(text)
      content_tag :h5, :class => "pmd_phrase_label" do
        text
      end
    end

    def page_title(text)
      content_tag :h1 do
        text
      end
    end

    def section_title(text, show_icon = true)
      if (show_icon)
        linkname = to_css_name(text)
        content_tag :h2 do
          str = link_to ("#" + linkname).to_s, {id: linkname, class: 'pmd_bookmarkable', title: 'permalink to this section'} do
            content_tag :i, class: 'icon-bookmark' do
            end
          end
          str += text
          str
        end
      else
        content_tag :h2 do
          text
        end

      end
    end

    def additional_format(format, link)
      if (@additional_formats.nil?)
        @additional_formats = [];
      end
      @additional_formats.push({format:format, link:link})
    end

    def additional_formats_for_resource(uri)
      format_options = {only_path:false, :uri => uri}
      additional_format('JSON', url_for(format_options.merge(format: 'json')))
      additional_format('RDF/XML', url_for(format_options.merge(format: 'rdf')))
      additional_format('Turtle', url_for(format_options.merge(format: 'ttl')))
      additional_format('N-triples', url_for(format_options.merge(format: 'nt')))
    end

    def link_to_sparql_tool_with_graph(graph_uri)
      sparql ="
        SELECT *
        WHERE {
            GRAPH <%{graph}> {
              ?s ?p ?o
            }
        }
        LIMIT 20"
      q = PublishMyData::SparqlQuery.new(sparql,:interpolations=>{:graph=>graph_uri})
      querystring = CGI.escape(q.query)
      link_to "open the SPARQL tool at this graph", "#{publish_my_data.sparql_endpoint_path}?&query=#{querystring}"
    end

    def maybe_link_to_vocabulary(dataset, obj)
      # FIXME this is probably slow
      dataset.ontologies.each_with_index do |ontology, index|
        uris = ontology.classes.map(&:uri) + ontology.properties.map(&:uri)
        if uris.any?{|u| obj == u}
          return content_tag :div do
            content_tag :small do
              "(Defined by ontology: #{link_to ontology.label || ontology.uri.to_s, resource_path_from_uri(ontology.uri)})".html_safe
            end
          end
        end
      end

      dataset.concept_schemes.each_with_index do |concept_scheme, index|
        uris = concept_scheme.concepts.map(&:uri)
        if uris.any?{|u| obj == u}
          return content_tag :div do
            content_tag :small do
              "(In concept scheme: #{link_to concept_scheme.label || concept_scheme.uri.to_s, resource_path_from_uri(concept_scheme.uri)})".html_safe
            end
          end
        end
      end

      return

    end

    # TODO - a better version of the above - but as yet only a partial implementation and requires ExampleResource.eager_load! to eager load all properties which might be slow
    #def link_to_vocabulary(resource, term)
    #  res = resource.get_related_resource(term, PublishMyData::Property)
    #  if (res && res.defined_by_ontology)
    #    onto = res.defined_by_ontology
    #    raw "<div><small>Defined by ontology: #{link_to onto.label || onto.uri, resource_path_from_uri(onto.uri)}</small></div>"
    #  end
    #end

  end
end
