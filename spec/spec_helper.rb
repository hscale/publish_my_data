# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'
require 'capybara/rails'
require 'active_support/core_ext/numeric/bytes'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# NB: Relative to the dummy app!
Dir[Rails.root.join("../support/*.rb")].each {|f| require f}

RSpec.configure do |config|

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = "random"

  config.mock_with :rspec

  config.before(:each) do
    # delete from all graphs.
    Tripod::SparqlClient::Update.update('
      # delete from default graph:
      DELETE {?s ?p ?o} WHERE {?s ?p ?o};
      # delete from named graphs:
      DELETE {graph ?g {?s ?p ?o}} WHERE {graph ?g {?s ?p ?o}};
    ')
  end

  config.before(:each, :type => :controller) do
    @request.host = 'pmdtest.dev'
  end

end

Capybara.configure do |config|
  config.default_host = 'http://pmdtest.dev'
end

# set up tripod for dev mode.
Tripod.configure do |config|
  config.update_endpoint = 'http://localhost:3030/pmdtest/update'
  config.query_endpoint = 'http://localhost:3030/pmdtest/sparql'
end
