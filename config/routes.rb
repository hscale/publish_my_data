PublishMyData::Engine.routes.draw do

  # resource show
  match "/resource(.:format)" => "resources#show" # http://resource?uri=http://foo.bar

  # resources lists
  match "/resources(.:format)" => "resources#index"

  # URI dereferencing
  match "/id/*path" => "resources#id"
  match "/doc/*path.:format" => "resources#doc"
  match "/doc/*path" => "resources#doc"

  # def pagges
  match "/def/*path.:format" => "resources#definition"
  match "/def/*path" => "resources#definition"

  #http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => 'errors#routing'
end
