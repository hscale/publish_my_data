require "publish_my_data/engine"
require "publish_my_data/concerns"
require "publish_my_data/renderers"
require "publish_my_data/sparql_query"
require "publish_my_data/sparql_query_result"
require "publish_my_data/defined_by_ontology"
require "publish_my_data/paginator"
require "publish_my_data/render_params"


module PublishMyData

  # The local domain of the website. Used to decide if resources andexdsf
  # datasets are local or not
  mattr_accessor :local_domain
  @@local_domain = 'pmd.dev'

  mattr_accessor :sparql_timeout_seconds
  @@sparql_timeout_seconds = 10

  mattr_accessor :sparql_endpoint
  @@sparql_endpoint = 'http://localhost:3030/pmd/sparql'

  mattr_accessor :tripod_cache_store
  @@tripod_cache_store = nil

  # max allowable size of a sparql response. Applies to all sparql requests. Allow at least 1K per resource for pages of resources.
  mattr_accessor :response_limit_bytes
  @@response_limit_bytes = 10.megabytes

  # default page size for lists of resources.
  mattr_accessor :default_resources_per_page
  @@default_resources_per_page = 20

  # Maximum allowable page size for lists of resources.
  # This is constrained by Fuseki's sparql request size. 500 is about the max it can handle (for lists of DESCRIBES).
  mattr_accessor :max_resources_per_page
  @@max_resources_per_page = 500

  # Use +configure+ to override PublishMyData configuration in an app, e.g.:
  # (defaults shown)
  #
  #   PublishMyData.configure do |config|
  #     config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
  #     config.local_domain = 'pmd.dev'
  #     config.sparql_timeout_seconds = 10
  #     config.response_limit_bytes = 10.megabytes
  #     config.default_resources_per_page = 20
  #     config.max_resources_per_page = 5000
  #     config.tripod_cache_store = nil #e.g Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
  #       # note: if using memcached, make sure you set the -I (slab size) to big enough to store each result (i.e. to more than SparqlQueryResult.MAX_SIZE)
  #       # and set the -m (total size) to something quite big (or the cache will recycle too often).
  #   end
  def self.configure
    yield self
  end

end

require 'kaminari'
require 'rdiscount'

Kaminari.configure do |config|
  config.default_per_page = 20
end
