module PublishMyData
  module SparqlProcessing
    extend ActiveSupport::Concern

    included do

      rescue_from PublishMyData::SparqlQueryExecutionException, :with => :show_sparql_execution_message
      rescue_from PublishMyData::SparqlQueryReservedVariablesException, :with => :reserved_variables
      rescue_from Tripod::SparqlQueryMissingVariables, :with => :missing_variables

      respond_to :html, :csv, :text, :nt, :ttl, :xml, :rdf, :json

      private

      def check_format
        unless request.format
          head :status => 406
          return false
        end
      end

      def build_sparql_query(query_text)
        @sparql_query = PublishMyData::SparqlQuery.new(query_text, {
          :request_format => request.format.to_sym,
          :interpolations => request.params.clone
        })

        @expected_variables = @sparql_query.expected_variables
        @interpolations = @sparql_query.interpolations
        # note: if there are missing variables, then this will be caught by them missing_variables error handler
      end

      # process the sparql query, paginating if appropriate
      def process_sparql_query(sparql_query)
        if sparql_query.allow_pagination?

          @pagination_params = SparqlPaginationParams.from_request(request)
          # if there are pagination paramters, then use them
          if @pagination_params.per_page && @pagination_params.page
            sparql_query_result = sparql_query.paginate(@pagination_params.page, @pagination_params.per_page)
            if is_request_html_format?
              @result_count = sparql_query.as_pagination_query(@pagination_params.page, @pagination_params.per_page, 1).count
              @more_pages = (@result_count > @pagination_params.per_page)
            end
          # otherwise just execute
          else
            sparql_query_result = @sparql_query.execute
          end
        else
          # pagination not allowed - just execute.
          sparql_query_result = @sparql_query.execute
        end

        add_json_p_callback(sparql_query_result)
      end

      def respond_with_error
        respond_to do |format|
          format.html { render 'publish_my_data/sparql/endpoint' }
          format.any { render :text => @error_message, :status => 400 }
        end
      end

      def missing_variables(e)
        @missing_variables = e.missing_variables
        @expected_variables = e.expected_variables
        @interpolations = e.received_variables
        @error_message = e.message
        respond_with_error
      end

      def reserved_variables(e)
        @reserved_variables_used = e.reserved_variables
        @expected_variables = e.expected_variables
        @interpolations = e.interpolations
        @error_message = e.message
        respond_with_error
      end

      def show_sparql_execution_message(e)
        @error_message = "There was a syntax error in your query: #{e.message}"
        respond_with_error
      end

      def add_json_p_callback(result)
        if request.format && request.format.json?
          params[:callback] ? "#{params[:callback]}(#{result});" : result
        else
          result
        end
      end
    end
  end
end