module PublishMyData
  class Engine < ::Rails::Engine
    isolate_namespace PublishMyData

    config.generators do |g|
      g.test_framework :rspec
    end

    config.autoload_paths << "./app/models/concerns"
    config.autoload_paths << "./app/controllers/concerns"

    initializer :myassets do |app|
      app.config.assets.paths << root.join("app", "assets", "fonts")
    end

  end
end
