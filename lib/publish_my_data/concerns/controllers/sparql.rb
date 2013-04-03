module PublishMyData
  module Concerns
    module Controllers
      module Sparql
        extend ActiveSupport::Concern

        included do

          rescue_from PublishMyData::SparqlQueryExecutionException, :with => :show_sparql_execution_message

          rescue_from PublishMyData::SparqlQueryMissingVariablesException, :with => :missing_variables

          respond_to :html, :csv, :text, :nt, :ttl, :xml, :rdf, :json

          private

          def check_format
            unless request.format
              head :status => 406
              return false
            end
          end

          def build_sparql_query(query_text)
            interpolations = request.params.reject{ |p| ['controller', 'action', 'page', 'per_page', 'id', 'commit' ,'utf8', 'query'].include?(p) }
            PublishMyData::SparqlQuery.new(query_text, {
              :request_format => request.format.to_sym,
              :interpolations => interpolations
            })
          end

          # process the sparql query, paginating if appropriate
          def process_sparql_query(sparql_query)
            if sparql_query.allow_pagination?

              @pagination_params = SparqlPaginationParams.from_request(request)

              # if there are paramters, then use them
              if @pagination_params.per_page && @pagination_params.page
                @sparql_query_result = sparql_query.paginate(@pagination_params.page, @pagination_params.per_page)
                if request.format.html?
                  count = sparql_query.as_pagination_query(@pagination_params.page, @pagination_params.per_page, 1).count
                  @more_pages = (count > @pagination_params.per_page)
                end
              # otherwise just execute
              else
                @sparql_query_result = @sparql_query.execute
              end
            else
              # pagination not allowed - just execute.
              @sparql_query_result = @sparql_query.execute
            end
          end

          def respond_with_error
            respond_to do |format|
              format.html { render 'publish_my_data/sparql/endpoint' }
              format.any { render :text => @error_message, :status => 400 }
            end
          end

          def missing_variables(e)
            @error_message = e.message
            respond_with_error
          end

          def show_sparql_execution_message(e)
            @error_message = "There was a syntax error in your query: #{e.message}"
            respond_with_error
          end

        end

      end
    end
  end
end