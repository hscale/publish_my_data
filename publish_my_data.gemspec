$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "publish_my_data/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "publish_my_data"
  s.version     = PublishMyData::VERSION
  s.authors     = ["Ric Roberts", "Bill Roberts", "Asa Calow", "Tekin Suleyman", "Guy Hilton"]
  s.email       = ["ric@swirrl.com"]
  s.homepage    = "http://github.com/Swirrl/publish_my_data"
  s.summary     = "PublishMyData Community Edition"
  s.description = "The PublishMyData Rails Engine. Create rails apps with Linked Data functionality."

  s.files = Dir["{app,config,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.md"]
  s.test_files = Dir["spec/**/*"]

  s.required_rubygems_version = ">= 1.3.6"
  s.rubyforge_project         = "publish_my_data"

  s.add_dependency "rails", "~> 3.2.11"
  s.add_dependency "tripod", "~> 0.4"
  s.add_dependency "rdf", "~> 1.0"
  s.add_dependency "kaminari"
  s.add_dependency "rdiscount"

end
