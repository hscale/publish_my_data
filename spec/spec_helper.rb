# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require_relative 'support/sparql_env_defaults'

require File.expand_path("../dummy/config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/autorun'
require 'factory_girl_rails'
require 'capybara/rails'
require 'active_support/core_ext/numeric/bytes'
require 'ap'
require 'term/ansicolor'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
# NB: Relative to the dummy app!
Dir[Rails.root.join("../support/*.rb")].each {|f| require f}

RSpec.configure do |config|
  config.filter_run(focus: true)
  config.run_all_when_everything_filtered = true

  # If true, the base class of anonymous controllers will be inferred
  # automatically. This will be the default behavior in future versions of
  # rspec-rails.
  config.infer_base_class_for_anonymous_controllers = false

  config.mock_with :rspec

  config.include(Term::ANSIColor)
  config.include(RDFHelpers)

  config.before(:each) do
    # delete from all graphs.
    begin
      Tripod::SparqlClient::Update.update("DROP ALL")
    rescue RestClient::ResourceNotFound
      puts red("Could not delete empty the database, have you specified the right endpoint?")
      puts cyan("Set the PMD_SPARQL_QUERY_* environment variables according to your Fuseki installation.")
      raise
    end
  end

  config.before(:each, :type => :controller) do
    @request.host = 'pmdtest.dev'
  end
end

require 'capybara/poltergeist'
Capybara.configure do |config|
  config.default_host = 'http://pmdtest.dev'
  config.javascript_driver = :poltergeist
end

# set up tripod for dev mode.
Tripod.configure do |config|
  config.update_endpoint = ENV.fetch("PMD_SPARQL_UPDATE_ENDPOINT")
  config.query_endpoint = ENV.fetch("PMD_SPARQL_QUERY_ENDPOINT")
  config.data_endpoint = ENV.fetch("PMD_SPARQL_DATA_ENDPOINT")
end
