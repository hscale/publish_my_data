require "publish_my_data/engine"
require "publish_my_data/renderers"
require "publish_my_data/sparql_query"
require "publish_my_data/sparql_query_result"
require "publish_my_data/resource_module"
require "publish_my_data/paginator"
require "publish_my_data/render_params"


module PublishMyData

  # The local domain of the website. Used to decide if resources andexdsf
  # datasets are local or not
  mattr_accessor :local_domain
  @@local_domain = 'pmd.dev'

  mattr_accessor :sparql_timeout_seconds
  @@sparql_timeout_seconds = 30

  mattr_accessor :sparql_endpoint
  @@sparql_endpoint = 'http://localhost:3030/pmd/sparql'

  mattr_accessor :tripod_cache_store

  # Use +configure+ to override PublishMyData configuration in an app, e.g.:
  # (defaults shown)
  #
  #   PublishMyData.configure do |config|
  #     config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
  #     config.local_domain = 'pmd.dev'
  #     config.sparql_timeout_seconds = 30
  #     config.tripod_cache_store = nil #e.g Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
  #       # note: if using memcached, make sure you set the -I (slab size) to big enough to store each result (i.e. to more than SparqlQueryResult.MAX_SIZE)
  #       # and set the -m (total size) to something quite big (or the cache will recycle too often).
  #   end
  def self.configure
    yield self
  end

end

require 'kaminari'

Kaminari.configure do |config|
  config.default_per_page = 20
end
