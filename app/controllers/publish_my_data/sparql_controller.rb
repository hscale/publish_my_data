require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    respond_to :html, :csv, :text, :nt, :ttl, :xml, :rdf, :json

    def endpoint
      @query_text = params[:query]

      if @query_text
        get_pagination_params

        @sparql_query = PublishMyData::SparqlQuery.new(@query_text, request.format.to_sym)
        @sparql_query_result = @sparql_query.paginate(@page, @per_page, 0)
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
