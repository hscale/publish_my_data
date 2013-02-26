# set up tripod for dev mode.
Tripod.configure do |config|
  config.query_endpoint = PublishMyData.sparql_endpoint
  config.cache_store = PublishMyData.tripod_cache_store
end
