require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    respond_to :html, :csv, :text, :nt, :ttl, :xml, :rdf, :json

    def endpoint
      # just deal with selects for now
      @query_text = params[:query]

      if @query_text
        @sparql_query = PublishMyData::SparqlQuery.new(@query_text, request.format.to_sym)
        @sparql_query_result = @sparql_query.execute() # this returns a SparqlQueryResult object
        respond_with(@sparql_query_result)
      end

    end

  end
end
