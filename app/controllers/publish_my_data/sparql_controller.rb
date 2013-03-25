require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    include PublishMyData::Concerns::Controllers::Sparql

    before_filter :check_format, :only => [:endpoint]

    def endpoint
      @query_text = params[:query]

      unless @query_text.blank?

        @sparql_query = build_sparql_query(@query_text)

        if @sparql_query.allow_pagination?
          paginate_sparql_query(@sparql_query)
        else
          @sparql_query_result = @sparql_query.execute
        end

        respond_with(@sparql_query_result)
      end

    end

  end
end
