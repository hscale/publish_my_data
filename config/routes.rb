PublishMyData::Engine.routes.draw do

  # resource show
  match "/resource(.:format)" => "resources#show" # http://resource?uri=http://foo.bar

  # resources lists
  match "/resources(.:format)" => "resources#index"

  # URI dereferencing
  match "id/*path" => "resources#id"
  match "doc/*path.:format" => "resources#doc"
  match "doc/*path" => "resources#doc"
end
