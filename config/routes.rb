PublishMyData::Engine.routes.draw do

  # resource show
  match "/resource(.:format)" => "resources#show", :as => 'show_resource' # http://resource?uri=http://foo.bar

  # resources lists
  match "/resources(.:format)" => "resources#index", :as => 'list_resources' # +filters on thh query string

  # datasets

  # note that the separate .:format and no-format verisons allow extensions like .json on the end of the uri not to be globbed as the *id
  match "/data/*id/dump" => "datasets#dump", :as => 'dataset_dump'
  match "/data/*id.:format" => "information_resources#data"
  match "/data/*id" => "information_resources#data", :as => 'dataset'
  match "/data(.:format)" => "datasets#index",  :as => 'datasets'

  # themes
  resources :themes, :only => [:index, :show]

  # URI dereferencing
  match "/id/*path" => "resources#id"
  match "/doc/*path.:format" => "resources#doc"
  match "/doc/*path" => "resources#doc"

  # download paths
  match "/def/ontology/*id/dump" => "ontologies#dump"
  match "/def/concept-scheme/*id/dump" => "concept_schemes#dump"
  match "/vocabularies/:id/dump" => "vocabularies#dump"

  # def pages
  match "/def/*id.:format" => "information_resources#def"
  match "/def/*id" => "information_resources#def"

  # queries
  resources :queries, :only => [:show] # add index later

  # SPARQL
  match "sparql(.:format)" => "sparql#endpoint", :as => 'sparql_endpoint' # the main sparql endpoint

  #http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => 'errors#routing'
end
