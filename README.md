# PublishMyData Community Edition.

## Overview

PublishMyData is a Rails Engine that adds Linked Data functionality to your Rails app including:

- URI dereferencing and displaying resources outside your site domain
- A SPARQL Endpoint
- Filterable lists of datasets and resources

## How to use

1. Add it to your Gemfile

        gem tripod

2. Configure it (in application.rb, or development.rb/production.rb/test.rb)

        PublishMyData.configure do |config|
          config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
          config.local_domain = 'pmd.dev'
          config.sparql_timeout_seconds = 30
          config.tripod_cache_store = Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
        end


## Notes

- PublishMyData uses [Tripod](http://github.com/Swirrl/tripod) for database access.
- See the Rails guides for [more details on Rails Engines](http://guides.rubyonrails.org/engines.html).
- PublishMyData doesn't supply a database. You need to install one. I recommend [Fuseki](http://jena.apache.org/documentation/serving_data/index.html), which runs on port 3030 by default.
- The views currently supplied by this Rails engine are very rudimentary. Some nicer default views coming soon, but for now you'll probably just want to override them all in your app.
- Warning: This gem is usable now, but the API is under constant development and flux at the moment

## Licence

Uses MIT-LICENSE.