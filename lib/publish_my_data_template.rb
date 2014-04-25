# run with:
#   rails new my_new_app --skip-active-record --skip-test-unit --template=/path/to/this/file 

say("replacing Gemfile", :yellow)

remove_file 'Gemfile'

# note: we have to use the full file path here as the source paths are set only in the generator (called later), but we need the Gemfile to be there to call that!
copy_file File.join(File.dirname(__FILE__), 'generators', 'publish_my_data', 'install', 'templates', 'Gemfile'), 'Gemfile'

say 'Installing dependencies'
system 'bundle install'

# now that we have the gemfile loaded, we can do everything in the generator.
say("Installing publish_my_data into #{@app_name}", :yellow)

run "rails generate publish_my_data:install #{@app_name}"

say("Finished!")