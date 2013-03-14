module PublishMyData
  module ResourceModule
    # Is this resource in the host domain?
    def in_domain?(domain)
      uri.starts_with?("http://" + domain)
    end
  end
end