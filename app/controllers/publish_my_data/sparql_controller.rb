require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    include PublishMyData::Concerns::Controllers::Sparql

    before_filter :check_format, :only => [:endpoint]

    def endpoint
      foo

      @query_text = params[:query]

      unless @query_text.blank?

        @sparql_query = build_sparql_query(@query_text)

        process_sparql_query(@sparql_query)

        respond_with(@sparql_query_result)
      end

    end

  end
end
