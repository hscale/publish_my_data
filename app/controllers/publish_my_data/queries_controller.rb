require_dependency "publish_my_data/application_controller"

module PublishMyData
  class QueriesController < ApplicationController

    include PublishMyData::SparqlProcessing

    before_filter :check_format, :only => [:show]

    # not implemented yet - will list all named queries
    # GET /queries/:id, where id is the slug.
    def show
      @query_text = get_query_sparql(params[:id])
      @sparql_query = build_sparql_query(@query_text)
      @sparql_query_result = process_sparql_query(@sparql_query)
      respond_with(@sparql_query_result) do |format|
        format.html { head :status => 406 }
      end
    end

    # not implemented yet - will list all named queries
    # GET /queries
    def index; end

    private

    def get_query_sparql(slug)
      sparql = queries_hash[slug]
      raise Tripod::Errors::ResourceNotFound.new unless sparql
      sparql
    end

    # for now this is a hard coded hash of all our queries. Override this in the
    # target app

    def queries_hash
      {'query-name' => 'sparql-goes-here'}
    end

  end
end
