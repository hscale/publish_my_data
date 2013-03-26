module PublishMyData
  module Concerns
    module Controllers
      module Sparql
        extend ActiveSupport::Concern

        included do

          rescue_from Tripod::Errors::SparqlResponseTooLarge, :with => :show_response_too_large_message
          rescue_from PublishMyData::SparqlQueryExecutionException, :with => :show_sparql_execution_message
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

          def interpolate_query(sparql_query)

          end

          def paginate_sparql_query(sparql_query)
            @pagination_params = PaginationParams.from_request(request)
            @sparql_query_result = sparql_query.paginate(@pagination_params.page, @pagination_params.per_page)
            if request.format.html?
              count = sparql_query.as_pagination_query(@pagination_params.page, @pagination_params.per_page, 1).count
              @more_pages = (count > @pagination_params.per_page)
            end
          end

          def respond_with_error
            respond_to do |format|
              format.html { render 'publish_my_data/sparql/endpoint' }
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
    end
  end
end