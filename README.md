# PublishMyData Community Edition

## Overview

PublishMyData is a [Rails Engine](http://guides.rubyonrails.org/engines.html) that adds Linked Data functionality to your Rails app including:

* URI dereferencing 
* displaying resources outside your site domain
* dataset pages to describe graphs of data with additional metadata
* A SPARQL Endpoint
* APIs for returning information about individual or fitlerable lists of resources
* default HTML views for datasets, resources, ontologies, concept schemes, etc.
* an extensible view and style framework using Engines, HAML, and Sass

This is the same core code that powers the enterprise, hosted version of PublishMyData. For more details see the [PublishMyData](http://publishmydata.com) website.

## Notes

- PublishMyData uses the [Tripod](http://github.com/Swirrl/tripod) ORM for database access.
- PublishMyData doesn't supply a database - you need to install and run a triple store yourself. We recommend [Fuseki](http://jena.apache.org/documentation/serving_data/index.html).
- better docs coming soon!

## Getting started

Also: see our [sample app](http://github.com/swirrl/sample_pmd) where we've already done all the below! (We'll make a _generator_ for these tasks soon).


1. Generate a new rails app (without active record or test-unit)

        rails new hello_world -O -T

2. Add publish_my_data to your Gemfile. The minimal contents of the gemfile are as follows
        
        source 'https://rubygems.org'
        gem 'rails', '3.2.15'
        gem 'publish_my_data'

3. Bundle.

        $ bundle

        Fetching gem metadata from https://rubygems.org/.........
        Fetching gem metadata from https://rubygems.org/..
        Resolving dependencies...
        ...
        Installing publish_my_data (1.2.0) 
        Your bundle is updated!

If you don't see `publish_my_data (1.2.0)` in the output you may need to run `bundle update publish_my_data`

4. Add the following line to production.rb

        config.assets.precompile += %w(modernizr.js publish_my_data.js) # <-- required for production

5. Configure PublishMyData (in `application.rb`, or `development|production|test.rb`)

        PublishMyData.configure do |config|
          config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
          config.local_domain = 'pmd.dev' # the domain under which your linked data resources URIs are minted
          config.sparql_timeout_seconds = 30
          config.tripod_cache_store = nil # Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
        end

6. Mount it in your `routes.rb`
      
        # Note that there is no default home page route for publish_my_data. You need to define your own. e.g.        
 
        get '/', to: redirect('/data'), as: :home # use the data catalogue

        # # or:
        # match '/' => 'home#home', as: 'home'
        

        mount PublishMyData::Engine, at: "/" 

7. Delete all files from the `public` dir except the `robots.txt`.

8. Create an application layout under `app/views/layouts/publish_my_data` (i.e. called `application.html.haml` or `application.html.erb` etc).  NOTE that if you create `application.html.haml` you should remove the existing `application.html.erb` file.
   It should provide content for `:head` and `:global_header`, then render `pmd_layout`. e.g.

        - content_for :head do
          %title
            My page title

        - content_for :global_header do
          My header here

        = render template: 'layouts/publish_my_data/pmd_layout'

9. Add the helpers in your app's `ApplicationController`, and derive from the PublishMyData engines application controller

        class ApplicationController < PublishMyData::ApplicationController
          protect_from_forgery 
          helper PublishMyData::Engine.helpers
          helper :all
        end

10. Remove `assets/stylesheets/application.css` and create a new file called `assets/stylesheets/application.scss` which contains the following lines:

        $pmdconfig_colour_link: #da0;
        /* [...optional style configuration...] */
        @import "publish_my_data.scss";

##Licence

Source code is licensed under the MIT-LICENSE included in this distribution.

###Attribution

If you create a website powered by PublishMyData, we'd really appreciate it if you [let us know](mailto:hello@swirrl.com), and also credit us on your website (e.g. with a link in the footer to [the github repo](http://github.com/swirrl/publish_my_data) or [our website](http://www.swirrl.com/publishmydata)). The default footer supplied by the engine does this for you.

### Licence Exceptions

The Swirrl logo, which is the mark of Swirrl IT Limited and is copyright ©2013-4 Swirrl IT Limited, is licensed for use with no modification or adaptation permitted. It may be reproduced for purposes of attribution, but not in any way that suggests that Swirrl endorses you or your use.

## Contributing

If you want to issue a patch, bug fix or feature, please just issue a pull request (with tests where appropriate). Before accepting your first pull request, we ask you to send us an email agreeing to assigning to Swirrl the copyright for all project contributions. We will release any contibutions under the MIT license.

### Style Guidelines

#### Ruby

We roughly try to follow [Github's Ruby Style Guide](https://github.com/styleguide/ruby).

#### HAML & Sass

Style guidelines for HAML & Sass coming soon




