PublishMyData::Engine.routes.draw do

  # resource show
  match "/resource(.:format)" => "resources#show", :as => 'show_resource' # http://resource?uri=http://foo.bar

  # resources lists
  match "/resources(.:format)" => "resources#index", :as => 'list_resources' # +filters on thh query string

  # datasets

  # data cube stuff
  match "/data/*id/cube/dimensions(.:format)" => "data_cube/dimensions#index" # list the dimensions for the cube
  match "/data/*id/cube/measure(.:format)" => "data_cube/dimensions#measure" # the measure property for the cube
  match "/data/*id/cube/dimension_values(.:format)" => "data_cube/dimensions#values" # all values for a single dimension in the cube. Useful for getting axes.
  match "/data/*id/cube/dimension_size(.:format)" => "data_cube/dimensions#size" # number of values for a dimension in the cube.
  match "/data/*id/cube/recommended_dimensions(.:format)" => "data_cube/dimensions#recommended" # recommended dimensions to use.
  match "/data/*id/cube/observations(.:format)" => "data_cube/observations#index", as: :cube_observations # supply row, col and locked dimensions as query string parameters

  # example resources for datasets
  match "/data/*id/example-data" => "example_resources#index", as: :example_resources

  # dumps
  match "/data/*id/dump" => "datasets#dump", :as => 'dataset_dump'

  # dataset resource
  # note that the separate .:format and no-format verisons allow extensions like .json on the end of the uri not to be globbed as the *id
  match "/data/*id.:format" => "information_resources#data"
  match "/data/*id" => "information_resources#data", :as => 'dataset'

  #dataset list
  match "/data(.:format)" => "datasets#index",  :as => 'datasets'

  # themes
  resources :themes, :only => [:index, :show]

  # URI dereferencing
  match "/id/*path" => "resources#id"
  match "/doc/*path.:format" => "resources#doc"
  match "/doc/*path" => "resources#doc"

  # download paths
  match "/def/*id/dump" => "information_resources#dump"
  match "/vocabularies/:id/dump" => "vocabularies#dump"

  # def pages
  match "/def/*id.:format" => "information_resources#def"
  match "/def/*id" => "information_resources#def"

  # queries
  resources :queries, :only => [:show] # add index later

  # SPARQL
  match "sparql(.:format)" => "sparql#endpoint", :as => 'sparql_endpoint' # the main sparql endpoint

  # Static pages
  match "/docs" => "home#docs", :as => 'developer_docs'
  match "/privacy" => "home#privacy", :as => 'privacy'
  match "/accessibility" => "home#accessibility", :as => 'accessibility'
  match "/" => 'home#home', :as => 'home'

  #http://techoctave.com/c7/posts/36-rails-3-0-rescue-from-routing-error-solution
  match '*a', :to => 'errors#routing'
end
