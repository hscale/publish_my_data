module PublishMyData
  module ResourceModule
    # Is this resource in the host domain?
    def local?
      uri.starts_with?("http://" + PublishMyData.local_domain)
    end
  end
end