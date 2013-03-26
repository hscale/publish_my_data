require 'spec_helper'

module PublishMyData
  describe SparqlController do
    describe "#endpoint" do

      context "with no query" do
        it "should not assign to sparql_query" do
          get :endpoint, use_route: :publish_my_data
          assigns["sparql_query"].should be_nil
        end

        it "should not assign to the pagination vars" do
          get :endpoint, use_route: :publish_my_data
          assigns['per_page'].should be_nil
          assigns['page'].should be_nil
        end

        it "should respond succesfully" do
          get :endpoint, use_route: :publish_my_data
          response.should be_success
        end
      end

      context "running a query" do

        it "should respond succesfully" do
          get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
          response.should be_success
        end

        context "if the query allows pagination (selects)" do

          it "should call paginate" do
            SparqlQuery.any_instance.should_receive(:paginate)
            get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
          end

          it "should pass the right params through to paginate" do
            SparqlQuery.any_instance.should_receive(:paginate).with(2, 35)
            get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :per_page => 35, :page => 2, use_route: :publish_my_data
          end

          context "with no page or per page paramteres supplied" do

            it "should set the page and per page variables to defaults" do
              get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
              assigns['pagination_params'].per_page.should == 20
              assigns['pagination_params'].page.should == 1
            end

          end

          context "with page and per page paramters supplied" do
            it "should apply the parameters to the variables" do
              get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :per_page => 35, :page => 2, use_route: :publish_my_data
              assigns['pagination_params'].per_page.should == 35
              assigns['pagination_params'].page.should == 2
            end
          end

          it "should call paginate on a sparql query object, with the right params" do
            SparqlQuery.any_instance.should_receive(:paginate).with(2, 35).and_call_original
            get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :per_page => 35, :page => 2, use_route: :publish_my_data
          end

        end


        context "if the query does not allow pagination (non-selects)" do
          it "should not call paginate" do
            SparqlQuery.any_instance.should_not_receive(:paginate)
            get :endpoint, :query => 'ASK {?s ?p ?o}', use_route: :publish_my_data
          end

          it "should call execute" do
            SparqlQuery.any_instance.should_receive(:execute)
            get :endpoint, :query => 'CONSTRUCT {?s ?p ?o}', use_route: :publish_my_data
          end

          it "should not set the pagination variables, even if params are supplied" do
            get :endpoint, :query => 'CONSTRUCT WHERE {?s ?p ?o}', :per_page => 35, :page => 2, use_route: :publish_my_data
            assigns['per_page'].should be_nil
            assigns['page'].should be_nil
          end
        end


        it "should create a SparqlQuery object with the query and assign to @sparql_query variable" do
           get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
           assigns['sparql_query'].class.should == SparqlQuery
           assigns['sparql_query'].query.should == 'SELECT ?s WHERE {?s ?p ?o}'
        end

        it "should assign a sparql query result object" do
          get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
          assigns['sparql_query_result'].class.should == SparqlQueryResult
        end

        context "if the response is too large" do

          context 'for html format' do
            before do
              SparqlQuery.any_instance.should_receive(:execute).and_raise(Tripod::Errors::SparqlResponseTooLarge)
              get :endpoint,  :query => 'SELECT * WHERE { ?s ?p ?o }', use_route: :publish_my_data
            end

            it "should set an error message" do
              assigns['error_message'].should_not be_blank
            end

            it "should respond succesfully" do
              response.should be_success
            end
          end

          context 'for a data format' do
            before do
              @request.env['HTTP_ACCEPT'] = "text/csv"
              SparqlQuery.any_instance.should_receive(:execute).and_raise(PublishMyData::SparqlQueryExecutionException)
              get :endpoint,  :query => 'SELECT * WHERE { ?s ?p ?o }', use_route: :publish_my_data
            end

            it "should respond with an empty body" do
              response.body.should be_blank
            end

            it "should respond with bad response" do
              response.status.should == 400
            end
          end

        end

        context "if there's an error executing the query" do

          context 'for html format' do
            before do
              SparqlQuery.any_instance.should_receive(:execute).and_raise(PublishMyData::SparqlQueryExecutionException)
              get :endpoint,  :query => 'DODGY QUERY', use_route: :publish_my_data
            end

            it "should set an error message" do
              assigns['error_message'].should_not be_blank
            end

            it "should respond succesfully" do
              response.should be_success
            end
          end

          context 'for a data format' do
            before do
              @request.env['HTTP_ACCEPT'] = "text/csv"
              SparqlQuery.any_instance.should_receive(:execute).and_raise(PublishMyData::SparqlQueryExecutionException)
              get :endpoint,  :query => 'DODGY QUERY', use_route: :publish_my_data
            end

            it "should respond with an empty body" do
              response.body.should be_blank
            end

            it "should respond with bad response" do
              response.status.should == 400
            end
          end
        end
      end

    end
  end
end
