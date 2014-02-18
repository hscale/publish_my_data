require 'tripod'

require "publish_my_data/engine"
require "publish_my_data/renderers"
require "publish_my_data/sparql_query"
require "publish_my_data/sparql_query_result"
require "publish_my_data/paginator"

# A bit nasty, but these paths are included by default in Rails 4 so
# this is only a temporary measure

require File.expand_path('../../app/models/concerns/publish_my_data/cube_results.rb', __FILE__)

# load them in the right order so that dataset powers can access all features.
require File.expand_path('../../app/models/concerns/publish_my_data/all_features.rb', __FILE__)
require File.expand_path('../../app/models/concerns/publish_my_data/basic_features.rb', __FILE__)
require File.expand_path('../../app/models/concerns/publish_my_data/dataset_powers.rb', __FILE__)
require File.expand_path('../../app/models/concerns/publish_my_data/defined_by_ontology.rb', __FILE__)
require File.expand_path('../../app/models/concerns/publish_my_data/cube_results.rb', __FILE__)

Dir[File.expand_path('../../app/controllers/concerns/**/*.rb', __FILE__)].each {|f| require f}


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

  # max allowable size of a sparql response. Applies to all sparql requests.
  # Note: Allow a few KB per resource (for max_resources_per_page config)
  mattr_accessor :response_limit_bytes
  @@response_limit_bytes = 5.megabytes

  # default page size for sparql-select results in the html interface
  mattr_accessor :default_html_sparql_per_page
  @@default_html_sparql_per_page = 20

  # default page size for lists of resources in the html interface
  mattr_accessor :default_html_resources_per_page
  @@default_html_resources_per_page = 20

  # Maximum allowable page size for lists of resources.
  mattr_accessor :max_resources_per_page
  @@max_resources_per_page = 1000

  # human reading name of your application as it will appear eg in page titles
  mattr_accessor :application_name
  @@application_name = "Your Application Name"

  mattr_accessor :logo_small
  @@logo_small = "/assets/publish_my_data/logo-placeholder.png"

  mattr_accessor :logo_large
  @@logo_large = "/assets/publish_my_data/logo-placeholder-large.png"

  # Use +configure+ to override PublishMyData configuration in an app, e.g.:
  # (defaults shown)
  #
  #   PublishMyData.configure do |config|
  #     config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
  #     config.local_domain = 'pmd.dev'
  #     config.sparql_timeout_seconds = 10
  #     config.response_limit_bytes = 10.megabytes
  #     config.default_html_resources_per_page = 20
  #     config.default_html_sparql_per_page = 20
  #     config.max_resources_per_page = 1000
  #     config.tripod_cache_store = nil #e.g Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
  #       # note: if using memcached, make sure you set the -I (slab size) to big enough to store each result (i.e. to more than SparqlQueryResult.MAX_SIZE)
  #       # and set the -m (total size) to something quite big (or the cache will recycle too often).
  #   end
  def self.configure
    yield self
  end

end

require 'rdf'
require 'kaminari'
require 'rdiscount'
require 'aws-sdk'
require 'rails_autolink'
require 'haml-rails'
require 'sass-rails'
require 'jquery-rails'

Kaminari.configure do |config|
  config.default_per_page = 20
end