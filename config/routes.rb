PublishMyData::Engine.routes.draw do
  match "/resource(.:format)" => "resources#show" # http://resource?uri=http://foo.bar
  match "/resources(.:format)" => "resources#index"
end
