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
      end

      context "with no page or per page paramteres supplied" do
        it "should set the page and per page variables to defaults" do
          get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
          assigns['per_page'].should == 100
          assigns['page'].should == 1
        end
      end

      context "with page and per page paramteres supplied" do
        it "should apply the paramters to the variables" do
          get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :_per_page => 35, :_page => 2, use_route: :publish_my_data
          assigns['per_page'].should == 35
          assigns['page'].should == 2
        end
      end

      it "should create a SparqlQuery object with the query and assign to @sparql_query variable" do
         get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
         assigns['sparql_query'].class.should == SparqlQuery
         assigns['sparql_query'].query.should == 'SELECT ?s WHERE {?s ?p ?o}'
      end

      it "should call paginate on a sparql query object, with the right params" do
        SparqlQuery.any_instance.should_receive(:paginate).with(2, 35, 0).and_call_original
        get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', :_per_page => 35, :_page => 2, use_route: :publish_my_data
      end

      it "should assign a sparql query result object" do
        get :endpoint, :query => 'SELECT ?s WHERE {?s ?p ?o}', use_route: :publish_my_data
        assigns['sparql_query_result'].class.should == SparqlQueryResult
      end

    end
  end
end
