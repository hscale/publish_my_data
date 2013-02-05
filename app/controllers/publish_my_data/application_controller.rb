module PublishMyData
  class ApplicationController < ActionController::Base

    rescue_from Tripod::Errors::ResourceNotFound, :with => :resource_not_found

    # TODO: handle:
    # 500s, timeouts (503) etc.

    private

    def resource_not_found(e)
      respond_to do |format|
        format.html { render(:template => "publish_my_data/errors/not_found", :layout => 'publish_my_data/error', :status => 404) and return false }
        #TODO: ? format.js { render(:template => "publish_my_data/errors/not_found", :status => 200) and return false } # need to return success or the ajax request fails
        format.any { head(:status => 404, :content_type => 'text/plain') and return false }
      end
    end
  end
end
