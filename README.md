# PublishMyData Community Edition.

## Overview

The PublishMyData Community Edition is a Rails Engine that adds Linked Data functionality to your Rails app including:

- URI dereferencing and displaying resources outside your site domain
- A SPARQL Endpoint
- Filterable lists of datasets and resources

This is the same core code that powers the enterprise, hosted version of PublishMyData. For more details see the [PublishMyData](http://publishmydata.com) website.

## How to use

1. Add it to your Gemfile

        gem publish_my_data

2. Configure it (in application.rb, or development.rb/production.rb/test.rb)

        PublishMyData.configure do |config|
          config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
          config.local_domain = 'pmd.dev'
          config.sparql_timeout_seconds = 30
          config.tripod_cache_store = Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
        end

3. Mount it in your routes.rb

        mount PublishMyData::Engine, at: "/"

## Notes

- PublishMyData uses [Tripod](http://github.com/Swirrl/tripod) for database access.
- See the Rails guides for [more details on Rails Engines](http://guides.rubyonrails.org/engines.html).
- PublishMyData doesn't supply a database. You need to install one. I recommend [Fuseki](http://jena.apache.org/documentation/serving_data/index.html), which runs on port 3030 by default.
- The views currently supplied by this Rails engine are very rudimentary. Some nicer default views coming soon, but for now you'll probably just want to override them all in your app.
- Warning: This gem is usable now, but the API is under constant development and flux at the moment, and tbh it's not very well documented! :)

## Development

PublishMyData is specified in and tested with an RSpec example suite. As PublishMyData is a Rails Engine, the `spec/` folder contains a dummy app which serves as a test harness for the engine.

To run the tests for PublishMyData you need to configure a local SPARQL database. This can be configured with the following environment variables:

* `PMD_SPARQL_QUERY_ENDPOINT` (default: _http://localhost:3030/pmd-test/sparql_)
* `PMD_SPARQL_UPDATE_ENDPOINT` (default: _http://localhost:3030/pmd-test/update_)

These are currently managed in `spec_helper.rb` and `PMD_SPARQL_QUERY_ENDPOINT` is read in the dummy app to configure the `test` environment. As PublishMyData Community Edition is read-only, `PMD_SPARQL_UPDATE_ENDPOINT` is only used in the test suite, to prepare example data.

## Licence

Uses MIT-LICENSE.