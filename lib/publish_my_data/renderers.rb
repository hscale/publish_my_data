require "action_controller"

# turtle
Mime::Type.register "text/turtle", :ttl # also allow requests without the charset
ActionController::Renderers.add :ttl do |obj, opts|
  str = obj.respond_to?(:to_ttl) ? obj.to_ttl : obj.to_s
  send_data str, :type => "text/turtle; charset=utf-8", :disposition => "inline"
end

#rdf
Mime::Type.register "application/rdf+xml", :rdf # also allow requests without the charset
ActionController::Renderers.add :rdf do |obj, opts|
  str = obj.respond_to?(:to_rdf) ? obj.to_rdf : obj.to_s
  send_data str, :type => "application/rdf+xml; charset=utf-8", :disposition => "inline"
end

#ntriples
# Note: We've elected not to respond with ntriples to text/plain as it confuses things
# (text/plain is used for plain-text tabular sparql-select results!
Mime::Type.register("application/n-triples", :nt) # note: ntriples is ASCII not utf-8

ActionController::Renderers.add :nt do |obj, opts|
  str = obj.respond_to?(:to_nt) ? obj.to_nt : obj.to_s
  send_data str, :type => Mime::NT, :disposition => "inline" # note: ntriples is ASCII not utf-8
end

# re-register JSON with extra headers
Mime::Type.unregister(:json)
Mime::Type.register "application/json", :json, %w( application/json text/x-json application/jsonrequest application/sparql-results+json )
# json already has a renderer

# likewise for XML
Mime::Type.unregister(:xml)
Mime::Type.register "application/xml", :xml, %w( application/xml text/xml application/x-xml application/sparql-results+xml )
# xml already has a renderer

# text mime type and renderer already defined

# csv mime type already registered.
# csv (for sparql SELECT results)
ActionController::Renderers.add :csv do |obj, opts|
  str = obj.respond_to?(:to_csv) ? obj.to_csv : obj.to_s
  send_data str, :type => Mime::CSV, :disposition => "inline"
end
