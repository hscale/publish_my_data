# PublishMyData Community Edition

## Important: v1.x in Maintenance mode only

*This repository is for version 1.x of PublishMyData, which is now in maintenance mode only.*

*Version 2.x is now available ([changelog](http://docs.publishmydata.com/changelog.html)), but is currently not open source. We are considering opening up components in the future.*

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

5. Configure PublishMyData (in development|production|test.rb`)

        PublishMyData.configure do |config|
          config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
          config.local_domain = 'pmd.dev' # the domain under which your linked data resources URIs are minted
          config.sparql_timeout_seconds = 30
          config.tripod_cache_store = nil # Tripod::CacheStores::MemcachedCacheStore.new('localhost:11211')
          config.application_name = "Your Application Name"
        end

6. Mount it in your `routes.rb`

        # Note that there is no default home page route for publish_my_data. You need to define your own. e.g.

        get '/', to: redirect('/data'), as: :home # use the data catalogue

        # # or:
        # match '/' => 'home#home', as: 'home'


        mount PublishMyData::Engine, at: "/"

6. In order for PublishMyData provided-views to be able to use helpers defined by our app, add the following to your `application.rb`:

        config.to_prepare do
          # include only the ApplicationHelper module in the PMD engine
          PublishMyData::ApplicationController.helper ApplicationHelper
          # # include all helpers from your application into the PMD engine
          # PublishMyData::ApplicationController.helper YourApp::Application.helpers
        end

7. Delete all files from the `public` dir except the `robots.txt`.

8. Create an application layout under `app/views/layouts/publish_my_data` (i.e. called `application.html.haml` or `application.html.erb` etc).  NOTE that if you create `application.html.haml` you should remove the existing `application.html.erb` file.
   It should provide content for `:head` and `:global_header`, then render `pmd_layout`. e.g.

        - content_for :head do
          %head
            %title
              = appname
              = yield :page_title

            = yield :page_description

            = javascript_include_tag :modernizr
            = javascript_include_tag :publish_my_data
            = stylesheet_link_tag :application

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

11. You can configure the navigation in your application by overriding the `views/publish_my_data/stripes/_subnav.html.haml` partial to pass in different `:menu` locals

        %nav.pmd_nav_sub
          = row do
            = render partial:'publish_my_data/shared/subnav_box', locals:{menu:standard_menu_catalogue}
            = render partial:'publish_my_data/shared/subnav_box', locals:{menu:standard_menu_tools}
            = render partial:'publish_my_data/shared/subnav_box', locals:{menu:alternative_menu_docs} # <-- # e.g. this line changed:
            = render partial:'publish_my_data/shared/subnav_box', locals:{menu:standard_menu_pmd}

If you define a new helper method to provide the locals (e.g. in our case `alternative_menu_docs`), it can build upon, and adapt the data stucture provided by the existing helpers in `publish_my_data/subnavigation_helper.rb`.

## Best practice: Developing with multiple Gemfiles

Sometimes when developing an application and the gem concurrently you may prefer to work against a local copy of PublishMyData.
If you don't want to risk accidentally committing a Gemfile which uses a local gem, there's a useful pattern to follow:

1) Make a new file at `local/Gemfile`. (You can put this anywhere, the `local/` part is just our convention).

2) Add something like the following to it

    # LOCAL GEMFILE
    # to use instead of defaul Gemfile:
    #
    # "bundle install --gemfile='local/Gemfile'"
    # "BUNDLE_GEMFILE=local/Gemfile bundle exec rails server"

    source 'https://rubygems.org'

    gem 'rails', '3.2.17'
    gem 'publish_my_data', :path => '../../publish_my_data'

Optionally, you may wish to gitignore this.

3) Do `bundle install --gemfile='local/Gemfile'` to create `local/Gemfile.lock`

4) Run your app with eg `BUNDLE_GEMFILE=local/Gemfile bundle exec rails server`

##Licence

All source code is copyright Swirrl IT Limited.

This project's source code is licensed under a dual license model: AGPL v3 and commercial. 

#### 1. The AGPL License

See the [GNU Affero General Public License](http://www.gnu.org/licenses/agpl-3.0.html) for full details.

AGPL is like GPL, but goes a bit further. The AGPL is a Free Software license that obligates you to make all the source code of your service available to users of that service. For example, if you are using PublishMyData on your server, to provide a SaaS service, you would have to give away all of your source code.

For example, this means that if you use PublishMyData to power a publicly accessible Rails app, you need to release the code for that app (under AGPL).

#### 2. A Commercial License

If you are not able to comply with the terms of the AGPL license, you can request an exemption or a commercial license by [contacting Swirrl](http://swirrl.com).

###Attribution

If you create a website powered by PublishMyData, we'd really appreciate it if you [let us know](mailto:hello@swirrl.com), and also credit us on your website (e.g. with a link in the footer to [the github repo](http://github.com/swirrl/publish_my_data) or [our website](http://www.swirrl.com/publishmydata)). The default footer supplied by the engine does this for you.

###Licence Exceptions

The Swirrl logo, which is the mark of Swirrl IT Limited and is copyright ©2013-4 Swirrl IT Limited, is licensed for use with no modification or adaptation permitted. It may be reproduced for purposes of attribution, but not in any way that suggests that Swirrl endorses you or your use.

##Contributing

If you want to issue a patch, bug fix or feature, please just issue a pull request (with tests where appropriate). Before accepting your first pull request, we ask you to send us an email agreeing to assigning to Swirrl the copyright for all project contributions. We will release any accepted contibutions under the AGPL license.

###Style Guidelines

####Ruby

We roughly try to follow [Github's Ruby Style Guide](https://github.com/styleguide/ruby).

#### CSS

We use [Idiomatic CSS](https://github.com/necolas/idiomatic-css).
