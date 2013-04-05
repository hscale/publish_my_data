require_dependency "publish_my_data/application_controller"

module PublishMyData
  class SparqlController < ApplicationController

    include PublishMyData::Concerns::Controllers::Sparql

    before_filter :check_format, :only => [:endpoint]

    def endpoint

      @query_text = params[:query]

      if @query_text.blank?
        unless request.format.html? #the html view handles this ok
          render :text => "no query supplied", :status => 400
        end
      else
        @sparql_query = build_sparql_query(@query_text)
        @sparql_query_result = process_sparql_query(@sparql_query)
        respond_with(@sparql_query_result)
      end

    end

  end
end
