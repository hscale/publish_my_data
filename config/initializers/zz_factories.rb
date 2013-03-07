# This loads all the factories, so they can be used by the rails console in target apps.
if Rails.env.development?
  path = File.expand_path("../../../spec/factories/*.rb", __FILE__)
  Dir[path].each do |factory|
    require factory
  end
end