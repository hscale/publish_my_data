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

    # from the criteria passed in, sets an instance var for @count and return
    # a Kaminari::PaginatableArray, or Array (as appropriate to the format)
    def paginate_resources(criteria)

      get_pagination_params unless @got_pagination_params

      @count = criteria.count #this has to happen first, before we modify the criteria with limit/offset
      resources = criteria.limit(@limit).offset(@offset).resources

      if request.format.html?
        Kaminari.paginate_array(resources.to_a, total_count: @count).page(@page).per(@limit)
      else
        resources # non html versions just need the raw array
      end
    end

    def get_pagination_params
      default_page_size = 20

      @per_page = (params[:per_page] || default_page_size).to_i
      @per_page = 10000 if @per_page > 10000
      @page = (params[:page] || 1).to_i

      @limit = @per_page
      @offset = @limit.to_i * (@page.to_i-1)

      @got_pagination_params = true
    end

  end
end
