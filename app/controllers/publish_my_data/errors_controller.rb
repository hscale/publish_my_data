#http://accuser.cc/posts/1-rails-3-0-exception-handling
module PublishMyData
  class ErrorsController < ApplicationController
    def routing
      # just re-raise a tripod not found error. Handled in Application Controller
      raise Tripod::Errors::ResourceNotFound
    end
  end
end