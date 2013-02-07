require "action_controller"

# turtle
Mime::Type.register("text/turtle", :ttl)
ActionController::Renderers.add :ttl do |obj, opts|
  str = obj.respond_to?(:to_ttl) ? obj.to_ttl : obj.to_s
  send_data str, :type => Mime::TTL, :disposition => "inline"
end

#rdf
Mime::Type.register("application/rdf+xml", :rdf)
ActionController::Renderers.add :rdf do |obj, opts|
  str = obj.respond_to?(:to_rdf) ? obj.to_rdf : obj.to_s
  send_data str, :type => Mime::RDF, :disposition => "inline"
end

#ntriples
Mime::Type.register("application/n-triples", :nt, %w( text/plain) ) # respond with ntriples to text/plain

ActionController::Renderers.add :nt do |obj, opts|
  str = obj.respond_to?(:to_nt) ? obj.to_nt : obj.to_s
  send_data str, :type => Mime::NT, :disposition => "inline"
end
