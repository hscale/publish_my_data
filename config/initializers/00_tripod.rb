Tripod.configure do |config|
  config.query_endpoint = PublishMyData.sparql_endpoint
  config.cache_store = PublishMyData.tripod_cache_store
  config.response_limit_bytes = PublishMyData.response_limit_bytes
  config.timeout_seconds = PublishMyData.sparql_timeout_seconds
  config.logger = Rails.logger
end
