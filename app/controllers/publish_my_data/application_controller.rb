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

      if Rails.env.development?
        #re-raise in dev mode.
        raise e
      else
        Raven.capture_exception(e) if defined?(Raven) # TODO: move this out of the CE.
        #log so the error appears in the rails log.
        Rails.logger.info ">>> UNCAUGHT ERROR"
        Rails.logger.info e.class.name
        Rails.logger.info e.message
        Rails.logger.info e.backtrace.join("\n")
        respond_to do |format|
          format.html { render(:template => "publish_my_data/errors/uncaught", :layout => 'publish_my_data/error', :status => 500) and return false }
          format.any{ head(:status => 500, :content_type => 'text/plain') and return false }
        end
      end

    end

    def handle_timeout(e)
      respond_to do |format|
        format.html { render(:template => "publish_my_data/errors/timeout", :layout => 'publish_my_data/error', :status => 503) and return false }
        format.any { head(:status => 503, :content_type => 'text/plain') and return false }
      end
    end

    def handle_resource_not_found(e)
      Rails.logger.info(">>> NOT FOUND")
      Rails.logger.info(e.inspect)
      Rails.logger.debug(e.backtrace.join("\n"))
      respond_to do |format|
        format.html { render(:template => "publish_my_data/errors/not_found", :layout => 'publish_my_data/error', :status => 404) and return false }
        format.any { head(:status => 404, :content_type => 'text/plain') and return false }
      end
    end

  end
end
