module PublishMyData
  class ApplicationController < ActionController::Base

    # Note: this order matters. Perversely, need to put more general errors first.
    rescue_from Exception, :with => :handle_uncaught_error
    rescue_from Tripod::Errors::ResourceNotFound, :with => :handle_resource_not_found
    rescue_from RestClient::RequestTimeout, :with => :handle_timeout

    private

    # TODO: deal with javaascript errors - respond with 200

    def handle_uncaught_error(e)
      @e = e
      # TODO: notify error handling service.
      respond_to do |format|
        format.html { render(:template => "publish_my_data/errors/uncaught", :layout => 'publish_my_data/error', :status => 500) and return false }
        format.any{ head(:status => 500, :content_type => 'text/plain') and return false }
      end

    end

    def handle_timeout(e)
      respond_to do |format|
        format.html { render(:template => "publish_my_data/errors/timeout", :layout => 'publish_my_data/error', :status => 503) and return false }
        format.any { head(:status => 503, :content_type => 'text/plain') and return false }
      end
    end

    def handle_resource_not_found(e)
      respond_to do |format|
        format.html { render(:template => "publish_my_data/errors/not_found", :layout => 'publish_my_data/error', :status => 404) and return false }
        format.any { head(:status => 404, :content_type => 'text/plain') and return false }
      end
    end

  end
end
