require 'spec_helper'

module PublishMyData
  describe SparqlController do

    shared_examples_for "a json-p response" do
      it "should wrap the response in the callback" do
        response.should be_success
        response.body.should eq('foo(json_results);')
      end
    end

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

        context "where the query expects parameters" do
          let(:query) {"select * where {?s ?%{p} ?%{o}}"}

          it "should assign the expected_variables" do
            get :endpoint, query: query, use_route: :publish_my_data
            assigns['expected_variables'].should == [:p, :o]
          end

          context "when a reserved parameter is used" do

            # page is reserved.
            let(:query) {"select * where {?s ?%{page} ?%{o}}"}
            let (:parameters) { {:query => query, :o => 'oh', :page => 1, use_route: :publish_my_data} }

            it "should be ignored" do
              get :endpoint, parameters
              assigns['missing_variables'].should == [:page]
            end

          end

          context "when all parameters supplied" do
            let (:parameters) { {:query => query, :o => 'oh', :p => 'pee', use_route: :publish_my_data} }

            it "should set the interpolations" do
              get :endpoint, parameters
              assigns['interpolations'].should == {"o" => 'oh', "p" => 'pee'}
            end

            it "should respond successfully" do
              get :endpoint, parameters
              response.should be_success
            end
          end

          context "when some parameters missing" do
            let (:parameters) { {:query => query, :o => 'oh', use_route: :publish_my_data} }

            it "should set the missing_variables" do
              get :endpoint, parameters
              assigns['missing_variables'].should == [:p]
            end

            it "should set the interpolations" do
              get :endpoint, parameters
              assigns['interpolations'].should == {"o" => 'oh'}
            end

            context "for html format" do
              before { get :endpoint, parameters }
              it 'should respond with success' do
                response.should be_success
              end
            end

            context "for non-html format" do
              before { get :endpoint, parameters.merge(format:'json') }

              it 'should respond with a 400' do
                response.code.should == "400"
              end

              it 'should include a message in the body' do
                response.body.should == "Missing parameters: p"
              end
            end

          end

        end

        context "non-html queries" do
          context 'for SELECTs' do

            let(:query) { 'SELECT ?s WHERE {?s ?p ?o}' }

            context "without pagination params" do
              let(:opts) { {:query => query, :format => 'csv', use_route: :publish_my_data} }

              it "should not call paginate" do
                SparqlQuery.any_instance.should_not_receive(:paginate)
                get :endpoint, opts
              end

              it "should just call execute" do
                SparqlQuery.any_instance.should_receive(:execute)
                get :endpoint, opts
              end

            end

            context "with pagination params" do
              let(:opts) { {:query => query, :per_page => 35, :page => 2, :format => 'csv', use_route: :publish_my_data} }

              it "should call paginate" do
                SparqlQuery.any_instance.should_receive(:paginate)
                get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
              end

              it "should pass the right params through to paginate" do
                SparqlQuery.any_instance.should_receive(:paginate).with(2, 35)
                get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :per_page => 35, :page => 2, use_route: :publish_my_data
              end

              it "should set the right pagination params" do
                get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :per_page => 35, :page => 2, use_route: :publish_my_data
                assigns['pagination_params'].per_page.should == 35
                assigns['pagination_params'].page.should == 2
              end

            end

            context "with a callback parameter" do
              context "for json" do

                context "with a header" do
                  before do
                    @request.env['HTTP_ACCEPT'] = "application/json"
                    SparqlQuery.any_instance.should_receive(:execute).and_return('json_results')
                    get :endpoint, :query => 'SELECT WHERE', :format => 'json', :callback => 'foo', use_route: :publish_my_data
                  end
                  it_should_behave_like "a json-p response"
                end

                context "with a format extension" do
                  before do
                    SparqlQuery.any_instance.should_receive(:execute).and_return('json_results')
                    get :endpoint, :query => 'SELECT WHERE', :format => 'json', :callback => 'foo', use_route: :publish_my_data
                  end
                  it_should_behave_like "a json-p response"
                end

              end
              context "for another format" do
                it "should not wrap the results" do
                  get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :format => 'txt', :callback => 'iamacallback', use_route: :publish_my_data
                  response.should be_success
                  response.body.should_not include('iamacallback')
                end
              end
            end
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
            assigns['pagination_params'].should be_nil
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

            it "should show the response_too_large template" do
              response.should render_template("publish_my_data/errors/response_too_large")
            end

            it "should respond with a 400" do
              response.status.should == 400
            end
          end

          context 'for a data format' do
            before do
              @request.env['HTTP_ACCEPT'] = "text/csv"
              SparqlQuery.any_instance.should_receive(:execute).and_raise(Tripod::Errors::SparqlResponseTooLarge)
              get :endpoint,  :query => 'SELECT * WHERE { ?s ?p ?o }', use_route: :publish_my_data
            end

            it "should respond with text in the body" do
              response.body.should == "Response too large."
            end

            it "should respond with bad response" do
              response.status.should == 400
            end
          end

        end

        context "if there's an error executing the query" do

          context 'for html format' do
            before do
              SparqlQuery.any_instance.should_receive(:execute).and_raise(PublishMyData::SparqlQueryExecutionException.new("foobar"))
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
              SparqlQuery.any_instance.should_receive(:execute).and_raise(PublishMyData::SparqlQueryExecutionException.new("foobar"))
              get :endpoint,  :query => 'DODGY QUERY', use_route: :publish_my_data
            end

            it "should respond with a message in the body" do
              response.body.should == "There was a syntax error in your query: foobar"
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
