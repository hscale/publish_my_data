Dummy::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin


  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  PublishMyData.configure do |config|
    config.sparql_endpoint = 'http://localhost:3030/pmd/sparql'
    config.local_domain = 'pmd.dev'

    config.downloads_s3_bucket = "publishmydata-dev"
    config.aws_access_key_id = "AKIAIMGJ3RKNJJ6CVGTA"
    config.aws_secret_access_key = "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"
  end

end
