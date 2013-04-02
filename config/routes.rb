PublishMyData::Engine.routes.draw do

  # resource show
  match "/resource(.:format)" => "resources#show", :as => 'show_resource' # http://resource?uri=http://foo.bar

  # resources lists
  match "/resources(.:format)" => "resources#index", :as => 'list_resources' # +filters on thh query string

  # datasets
  match "/data/:id(.:format)" => "datasets#show", :as => 'dataset'
  match "/data/:id/dump" => "datasets#dump", :as => 'dataset_dump'
  match "/data(.:format)" => "datasets#index",  :as => 'datasets'

  resources :datasets, :only => [:index, :show]

  # themes
  resources :themes, :only => [:index, :show]

  # URI dereferencing
  match "/id/*path" => "resources#id"
  match "/doc/*path.:format" => "resources#doc"
  match "/doc/*path" => "resources#doc"

  # def pages
  match "/def/*path.:format" => "resources#definition"
  match "/def/*path" => "resources#definition"

  # queries
  resources :queries, :only => [:show] # add index later

  # SPARQL
  match "sparql(.:format)" => "sparql#endpoint", :as => 'sparql_endpoint' # the main sparql endpoint

  #http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => 'errors#routing'
end
