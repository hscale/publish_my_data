require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    rescue_from PublishMyData::SparqlQueryResultTooLargeException, :with => :show_response_too_large_message
    rescue_from PublishMyData::SparqlQueryExecutionException, :with => :show_sparql_execution_message

    respond_to :html, :csv, :text, :nt, :ttl, :xml, :rdf, :json

    def endpoint
      @query_text = params[:query]

      unless @query_text.blank?
        @sparql_query = PublishMyData::SparqlQuery.new(@query_text, request.format.to_sym)

        if @sparql_query.allow_pagination?
          get_pagination_params
          @sparql_query_result = @sparql_query.paginate(@page, @per_page)
          @more_pages = @sparql_query.as_pagination_query(@page, @per_page, 1).count > @per_page if request.format.html?
        else
          @sparql_query_result = @sparql_query.execute
        end

        respond_with(@sparql_query_result)
      end

    end

    private

    def respond_with_error
      respond_to do |format|
        format.html { render 'endpoint' }
        format.any { head :status => 400 }
      end
    end

    def show_response_too_large_message(e)
      @error_message = "The results for this query are too large to return."
      respond_with_error
    end

    def show_sparql_execution_message(e)
      @error_message = "There was a syntax error in your query: #{e.message}"
      respond_with_error
    end

  end
end
