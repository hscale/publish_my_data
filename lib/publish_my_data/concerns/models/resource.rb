module PublishMyData
  module Concerns
    module Models
      module Resource
        extend ActiveSupport::Concern

        # Is this resource in the host domain?
        def in_domain?(domain)
          uri.starts_with?("http://" + domain)
        end
      end
    end
  end
end