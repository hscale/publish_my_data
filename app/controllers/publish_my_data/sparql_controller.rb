require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    respond_to :html, :csv, :text, :nt, :ttl, :xml, :rdf, :json

    def endpoint
      @query_text = params[:query]

      unless @query_text.blank?

        @sparql_query = PublishMyData::SparqlQuery.new(@query_text, request.format.to_sym)

        if @sparql_query.allow_pagination?
          get_pagination_params
          @sparql_query_result = @sparql_query.paginate(@page, @per_page)
        else
          @sparql_query_result = @sparql_query.execute
        end

        respond_with(@sparql_query_result)
      end

    end

    private

    def get_pagination_params
      @page = (params[:_page] || 1).to_i
      @per_page = (params[:_per_page] || 100).to_i
    end

  end
end
