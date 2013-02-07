require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    respond_to :html

    def endpoint
      # just deal with selects for now
      @query_text = params[:query]

      if @query_text
        @sparql_query = PublishMyData::SparqlQuery.new(@query_text, request.format)
        @query_result = @sparql_query.execute()
      end
    end

  end
end

#Tripod::SparqlClient::Query.select(@query, 'text')