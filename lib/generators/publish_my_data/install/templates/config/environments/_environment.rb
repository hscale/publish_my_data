  
  PublishMyData.configure do |config|
    config.sparql_endpoint = 'http://localhost:3030/__APPLICATION-NAME__-__ENVIRONMENT__/sparql'
    config.local_domain = 'example.com'
    config.sparql_timeout_seconds = 30
    config.tripod_cache_store = nil # Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
    config.application_name = '__TITLEIZED-APPLICATION-NAME__'
  end

