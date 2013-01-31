$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "publish_my_data/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "publish_my_data"
  s.version     = PublishMyData::VERSION
  s.authors     = ["Ric Roberts", "Bill Roberts", "Asa Calow", "Tekin Suleyman", "Guy Hilton"]
  s.email       = ["ric@swirrl.com"]
  s.homepage    = "http://publishmydata.com"
  s.summary     = "PublishMyData Community Edition"
  s.description = "The PublishMyData Rails Engine. Create rails apps with Linked Data functionality."

  s.files = Dir["{app,config,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["spec/**/*"]

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "tripod", "~> 0.1"

  s.add_development_dependency "rspec-rails", "~> 2.0"

end
