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

1. Generate a new Rails app with the following command, ensuring the path to your `publish_my_data` project is correct:

        rails new hello_world --skip-active-record --skip-test-unit --skip-bundle --template=/path/to/publish_my_data/lib/publish_my_data_template.rb

2. *If using Fuseki:*

   Start your Fuseki server using the generated configuration at `config/pmd.ttl`. For example:

        cd /usr/local/jena-fuseki-1.0.0; ./fuseki-server --config=/path/to/hello_world/config/pmd.ttl

3. Start your Rails server:

        rails server

## Before going live

1. Foo

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
