class ApplicationController < PublishMyData::ApplicationController
  protect_from_forgery
  helper PublishMyData::Engine.helpers
  helper :all
end