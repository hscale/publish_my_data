PublishMyData::Engine.routes.draw do

  # resource show
  match "/resource(.:format)" => "resources#show", :as => 'show_resource' # http://resource?uri=http://foo.bar

  # resources lists
  match "/resources(.:format)" => "resources#index", :as => 'list_resources' # +filters on thh query string

  # datasets
  resources :datasets, :only => [:show, :index]

  # URI dereferencing
  match "/id/*path" => "resources#id"
  match "/doc/*path.:format" => "resources#doc"
  match "/doc/*path" => "resources#doc"

  # def pages
  match "/def/*path.:format" => "resources#definition"
  match "/def/*path" => "resources#definition"

  # SPARQL
  match "sparql" => "sparql#endpoint", :as => 'sparql_endpoint' # the main sparql endpoint

  #http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => 'errors#routing'
end
