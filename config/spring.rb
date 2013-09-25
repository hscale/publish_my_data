Spring.application_root = "./spec/dummy"

Spring.watch "spec/factories"
Spring.watch_method = :listen

require_relative '../spec/support/sparql_env_defaults'