module PublishMyData
  module Generators
    class InstallGenerator < Rails::Generators::Base
      source_root File.expand_path("../templates", __FILE__)
      argument :app_name, type: :string, default: "my_app"

      desc "Sets up a publish_my_data app"
      
      def set_production_precompile_assets
        gsub_file 'config/environments/production.rb', /config.assets.precompile.*/, 'config.assets.precompile += %w( modernizr.js publish_my_data.js )'
        uncomment_lines 'config/environments/production.rb', /config.assets.precompile.*/
      end

      def set_environment_configuration
        %w{development production test}.each do |environment|
          content = File.open("#{source_paths.first}/config/environments/_environment.rb", "rb").read
          content.gsub!('__TITLEIZED-APPLICATION-NAME__', app_name.titleize)
          content.gsub!('__APPLICATION-NAME__', app_name.dasherize.downcase)
          content.gsub!('__ENVIRONMENT__', environment)

          inject_into_file "config/environments/#{environment}.rb", content, before: /^end/
        end
      end

      def remove_public_files
        remove_file 'public/index.html'
        remove_file 'public/404.html'
        remove_file 'public/422.html'
        remove_file 'public/500.html'
        remove_file 'public/favicon.ico'
      end

      def set_default_routes
        content = File.open("#{source_paths.first}/config/_routes.rb", "rb").read
        inject_into_file "config/routes.rb", content, before: /^end/
      end

      def add_helpers
        content = File.open("#{source_paths.first}/config/_application.rb", "rb").read
        inject_into_file "config/application.rb", content, before: /end(\s)+^end/
      end

      def set_application_layout
        remove_file "app/views/layouts/application.html.erb"
        copy_file "app/views/layouts/application.html.haml", "app/views/layouts/application.html.haml"
      end

      def set_application_controller
        remove_file "app/controllers/application_controller.rb"
        copy_file "app/controllers/application_controller.rb", "app/controllers/application_controller.rb"
      end

      def set_application_helper
        remove_file "app/helpers/application_helper.rb"
        copy_file "app/helpers/application_helper.rb", "app/helpers/application_helper.rb"
      end

      def set_application_css
        remove_file "app/assets/stylesheets/application.css"
        copy_file "app/assets/stylesheets/application.scss", "app/assets/stylesheets/application.scss"
      end

      def add_subnav_partial
        copy_file "app/views/publish_my_data/stripes/_subnav.html.haml", "app/views/publish_my_data/stripes/_subnav.html.haml"
      end

      def add_shared_head_partial
        copy_file "app/views/shared/_head.html.haml", "app/views/shared/_head.html.haml"
      end

      def add_shared_nav_partial
        copy_file "app/views/shared/_nav.html.haml", "app/views/shared/_nav.html.haml"
      end

      def add_gitignore
        remove_file ".gitignore"
        copy_file ".gitignore", ".gitignore"
      end

      def add_fuseki_config
        copy_file "config/pmd.ttl", "config/pmd.ttl"
        gsub_file "config/pmd.ttl", "__APPLICATION-NAME__", app_name.dasherize.downcase

        say "Fuseki config added to config/pmd.ttl", :yellow
      end

    end
  end
end
