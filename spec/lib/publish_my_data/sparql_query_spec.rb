require 'spec_helper'

module PublishMyData

  describe SparqlQuery do

    describe '#initialize' do
      context 'given a query without prefixes' do
        it 'should assign the given query to the body attribute' do
          q = PublishMyData::SparqlQuery.new('SELECT xyz')
          q.body.should == 'SELECT xyz'
        end
      end

      context 'given a query with prefixes' do
        it 'should separate the query into prefixes and body' do
          q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT xyz')
          q.prefixes.should == 'PREFIX e: <http://example.com>'
          q.body.should == 'SELECT xyz'
        end
      end

      context 'interpolations_supplied' do
        it 'should call interpolate, passing the interpolations' do
          q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT %{interpolate_me}',
            :interpolations => {:interpolate_me => 'xyz'})
          q.prefixes.should == 'PREFIX e: <http://example.com>'
          q.body.should == 'SELECT xyz'
          q.query.should == 'PREFIX e: <http://example.com> SELECT xyz'
        end

        it 'should replace the %-denoted interpolations using the hash provided' do
          PublishMyData::SparqlQuery.new(
            "SELECT %{foo} WHERE %{bar}", :interpolations => {:foo => 'baz', :bar => 'bozo'}
          ).query.should == "SELECT baz WHERE bozo"
        end

        it 'should work where the same variable is used more than once' do
          PublishMyData::SparqlQuery.new(
            "SELECT %{foo} WHERE %{foo}", :interpolations => {:foo => 'baz'}
            ).query.should == "SELECT baz WHERE baz"
        end
      end

      context 'interpolations missing' do
        it 'shoud throw an exception if interpolation variables are missing' do
          expect { PublishMyData::SparqlQuery.new(
            "SELECT %{foo} WHERE %{bar} %{baz}", :interpolations => {:foo => 'baz'}
            ) }.to raise_error(PublishMyData::SparqlQueryMissingVariablesException, "Missing parameters: bar, baz")
        end
      end
    end

    describe "#has_prefixes?" do

      context "for a query with prefixes" do
        it "should return true" do
          q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT xyz')
          q.has_prefixes?.should be_true
        end
      end

      context "for a query without prefixes" do
        it "should return false" do
          q = PublishMyData::SparqlQuery.new('SELECT xyz')
          q.has_prefixes?.should be_false
        end
      end

    end

    describe "#query_type" do

      it 'should return :select given a SELECT query' do
        q = PublishMyData::SparqlQuery.new('SELECT xyz')
        q.query_type.should == :select
      end

      it 'should return :construct given a CONSTRUCT query' do
        q = PublishMyData::SparqlQuery.new('CONSTRUCT <xyz>')
        q.query_type.should == :construct
      end

      it 'should return :construct given a DESCRIBE query' do
        q = PublishMyData::SparqlQuery.new('DESCRIBE <xyz>')
        q.query_type.should == :describe
      end

      it 'should return :ask given an ASK query' do
        q = PublishMyData::SparqlQuery.new('ASK <xyz>')
        q.query_type.should == :ask
      end

      it "should return :unknown given an unknown type" do
        q = PublishMyData::SparqlQuery.new('FOO <xyz>')
        q.query_type.should == :unknown
      end
    end

    describe '#expected_variables' do

      context 'interpolations required' do
        it 'should be an array of symbols representing the expected variables in the query' do
          q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT %{hello} %{good_bye}',
            :interpolations => {:hello => 'hello', :good_bye => 'good bye'})
          q.expected_variables.should == [:hello, :good_bye]
        end
      end

      context "interpolations don't appear in query" do
        it 'should be empty array' do
          q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT x')
          q.expected_variables.should == []
        end
      end

    end

    describe "#execute" do

      # load some data
      before do
        @yuri = FactoryGirl.create(:yuri_unicorn_resource)
        @boris = FactoryGirl.create(:boris_unicorn_resource)
      end

      context "with a SELECT query" do

        before do
          @query_str = 'SELECT * WHERE {?s ?p ?o}'
          @q = PublishMyData::SparqlQuery.new(@query_str)
        end

        it "should call Tripod::SparqlClient::Query.select with the right args" do
          Tripod::SparqlClient::Query.should_receive(:query).with(@query_str, "*/*", {:output => @q.send(:select_format_str)}).and_call_original
          @q.execute
        end

        it "should return some data in a SparqlQueryResult object" do
          result = @q.execute
          result.class.should == SparqlQueryResult
          result.to_s.should_not be_blank
        end

      end

      context "with an ASK query" do

        before do
          @query_str = 'ASK {?s ?p ?o}'
          @q = PublishMyData::SparqlQuery.new(@query_str)
        end

        it "should call Tripod::SparqlClient::Query.ask with the right args" do
          Tripod::SparqlClient::Query.should_receive(:query).with(@query_str, "*/*", {:output => @q.send(:ask_format_str)}).and_call_original
          @q.execute
        end

        it "should return some data in a SparqlQueryResult object" do
          result = @q.execute
          result.class.should == SparqlQueryResult
          result.to_s.should_not be_blank
        end

      end

      context "with a construct query" do

        before do
          @query_str = 'CONSTRUCT { ?s ?p ?o } WHERE { ?s ?p ?o }'
          @q = PublishMyData::SparqlQuery.new(@query_str)
        end

        it "should call Tripod::SparqlClient::Query.construct with the right args" do
          Tripod::SparqlClient::Query.should_receive(:query).with(@query_str, @q.send(:construct_or_describe_header)).and_call_original
          @q.execute
        end

        it "should return some data in a SparqlQueryResult object" do
          result = @q.execute
          result.class.should == SparqlQueryResult
          result.to_s.should_not be_blank
        end

      end

      context "with a DESCRIBE query" do

        before do
          @query_str = "DESCRIBE <#{@yuri.uri.to_s}>"
          @q = PublishMyData::SparqlQuery.new(@query_str)
        end

        it "should call Tripod::SparqlClient::Query.select with the right args" do
          Tripod::SparqlClient::Query.should_receive(:query).with(@query_str, @q.send(:construct_or_describe_header)).and_call_original
          @q.execute
        end

        it "should return some data in a SparqlQueryResult object" do
          result = @q.execute
          result.class.should == SparqlQueryResult
          result.to_s.should_not be_blank
        end
      end

      context "with an unknown query type" do
        before do
          @query_str = "FOOBAR <#{@yuri.uri.to_s}>"
          @q = PublishMyData::SparqlQuery.new(@query_str)
        end

        it "should raise an exception" do
          lambda { @q.execute }.should raise_error( SparqlQueryExecutionException )
        end
      end

      context "with a syntax error in the query" do

        context "for query without a parent" do
          it "should return the error from this query" do
            query_str = "SELECT * WHERE ?s ?p ?o}"
            q = PublishMyData::SparqlQuery.new(query_str)
            lambda {
              q.execute
            }.should raise_error(
              PublishMyData::SparqlQueryExecutionException, /line 1, column 16/
            )
          end
        end

        context "for a query with a parent" do
          it "should return the error from the original query" do
            query_str = "SELECT * WHERE ?s ?p ?o}"
            q = PublishMyData::SparqlQuery.new(query_str)
            lambda {
              q.count
            }.should raise_error(
              PublishMyData::SparqlQueryExecutionException, /line 1, column 16/
            )
          end
        end
      end

    end

    describe "#select_format_str" do

      before do
        @query_str = 'SELECT xyz'
      end
      context "where the request format is not specified" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str)
          q.send(:select_format_str).should == "text"
        end
      end

      context "where the request format is html" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str)
          q.send(:select_format_str).should == "text"
        end
      end

       context "where the request format is text" do
        it "should return 'csv'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :text)
          q.send(:select_format_str).should == "text"
        end
      end

      context "where the request format is json" do
        it "should return 'json'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :json)
          q.send(:select_format_str).should == "json"
        end
      end

      context "where the request format is csv" do
        it "should return 'csv'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :csv)
          q.send(:select_format_str).should == "csv"
        end
      end

      context "where the request format is xml" do
        it "should return 'xml'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :xml)
          q.send(:select_format_str).should == "xml"
        end
      end

      context "where the request format is something random" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :bananas)
          q.send(:select_format_str).should == "text"
        end
      end
    end

    describe "#ask_format_str" do

      before do
        @query_str = 'ASK xyz'
      end
      context "where the request format is not specified" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str)
          q.send(:ask_format_str).should == "text"
        end
      end

      context "where the request format is html" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str)
          q.send(:ask_format_str).should == "text"
        end
      end

      context "where the request format is csv" do
        it "should return 'csv'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :text)
          q.send(:ask_format_str).should == "text"
        end
      end

      context "where the request format is json" do
        it "should return 'json'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :json)
          q.send(:ask_format_str).should == "json"
        end
      end

      context "where the request format is xml" do
        it "should return 'xml'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :xml)
          q.send(:ask_format_str).should == "xml"
        end
      end

      context "where the request format is something random" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :bananas)
          q.send(:ask_format_str).should == "text"
        end
      end
    end

    describe "#construct_or_describe_header" do

      before do
        @query_str = 'CONSTRUCT xyz'
      end

      context "where the request format is not specified" do
        it "should return nt header" do
          q = PublishMyData::SparqlQuery.new(@query_str)
          q.send(:construct_or_describe_header).should == Mime::NT
        end
      end

      context "where the request format is html" do
        it "should return nt header'" do
          q = PublishMyData::SparqlQuery.new(@query_str)
          q.send(:construct_or_describe_header).should == Mime::NT
        end
      end


      context "where the request format is ttl" do
        it "should return ttl header" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :ttl)
          q.send(:construct_or_describe_header).should == Mime::TTL
        end
      end

       context "where the request format is rdf" do
        it "should return rdf header" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :rdf)
          q.send(:construct_or_describe_header).should == Mime::RDF
        end
      end

      context "where the request format is something random" do
        it "should return ntriples header" do
          q = PublishMyData::SparqlQuery.new(@query_str, :request_format => :bananas)
          q.send(:construct_or_describe_header).should == Mime::NT
        end
      end
    end

    describe "#as_count_query" do
      context "for non-selects" do
        it "should throw an exception" do
          lambda {
            q = PublishMyData::SparqlQuery.new('ASK { ?s ?p ?o }')
            q.as_count_query
          }.should raise_error(Tripod::SparqlQueryError, "Can't turn this into a subquery")
        end
      end

      context "for selects" do

        it "should return a new Sparql query with the original query as the parent" do
          q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
          q.as_count_query.parent_query.query.should == 'SELECT ?s WHERE { ?s ?p ?o }'
        end

        context 'without prefixes' do
          it "should return a new SparqlQuery with the original query wrapped in a count" do
            q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
            q.as_count_query.class.should == SparqlQuery
            q.as_count_query.query.should == 'SELECT (COUNT(*) as ?tripod_count_var) {
  SELECT ?s WHERE { ?s ?p ?o }
}'
          end
        end

        context 'with prefixes' do
          it "should move the prefixes to the start" do
            q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT ?s WHERE { ?s ?p ?o }')
            q.as_count_query.query.should == 'PREFIX e: <http://example.com> SELECT (COUNT(*) as ?tripod_count_var) {
  SELECT ?s WHERE { ?s ?p ?o }
}'
          end
        end
      end
    end

    describe "#paginate" do

      it "should execute the query as a pagination query" do
        q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
        pagination_q = double("SparqlQuery")
        q.should_receive(:as_pagination_query).and_return(pagination_q)
        pagination_q.should_receive(:execute)
        q.paginate(1,20,0)
      end

      it "should pass the parameters through to as_pagination_query" do
        q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
        q.should_receive(:as_pagination_query).with(3,40,1).and_call_original
        q.paginate(3,40,1)
      end
    end

    describe "#count" do
      before do
        @q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
        count_q = double("SparqlQuery")
        @q.should_receive(:as_count_query).and_return(count_q)
        count_q.should_receive(:execute).and_return('{
          "head": {
            "vars": [ "tripod_count_var" ]
          } ,
          "results": {
            "bindings": [
              {
                "tripod_count_var": { "datatype": "http://www.w3.org/2001/XMLSchema#integer" , "type": "typed-literal" , "value": "2" }
              }
            ]
          }
        }')
      end

      it "should execute the query as a count query and return an integer" do
        @q.count.class.should == Fixnum
      end

    end

    describe "#as_pagination_query" do

      context "for non-selects" do
        it "should throw an exception" do
          lambda {
            q = PublishMyData::SparqlQuery.new('ASK { ?s ?p ?o }')
            q.as_pagination_query(1, 20, 0)
          }.should raise_error(Tripod::SparqlQueryError, "Can't turn this into a subquery")
        end
      end

      context "for selects" do

        it "should return a new Sparql query with the original query as the parent" do
          q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
          q.as_pagination_query(1, 20, 0).parent_query.query.should == 'SELECT ?s WHERE { ?s ?p ?o }'
        end

        context "without prefixes" do

          it "should return a new SparqlQuery with the original query wrapped in a pagination subquery" do
            q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
            q.as_pagination_query(1, 20, 0).class.should == SparqlQuery
            # try a couple of different combos of pagination params
            q.as_pagination_query(1, 20, 0).query.should == 'SELECT * {
  SELECT ?s WHERE { ?s ?p ?o }
}
LIMIT 20 OFFSET 0'
            q.as_pagination_query(1, 20, 1).query.should == 'SELECT * {
  SELECT ?s WHERE { ?s ?p ?o }
}
LIMIT 21 OFFSET 0'
            q.as_pagination_query(2, 10, 0).query.should == 'SELECT * {
  SELECT ?s WHERE { ?s ?p ?o }
}
LIMIT 10 OFFSET 10'
            q.as_pagination_query(3, 10, 1).query.should == 'SELECT * {
  SELECT ?s WHERE { ?s ?p ?o }
}
LIMIT 11 OFFSET 20'
          end
        end

        context "with prefixes" do
          it "should move the prefixes to the start" do
            q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT ?s WHERE { ?s ?p ?o }')
            q.as_pagination_query(1, 20, 0).query.should == 'PREFIX e: <http://example.com> SELECT * {
  SELECT ?s WHERE { ?s ?p ?o }
}
LIMIT 20 OFFSET 0'
          end
        end

        context "with an existing subselect" do
          it "should wrap the select as for a normal select" do
            q = PublishMyData::SparqlQuery.new('SELECT * {
  SELECT ?s WHERE { ?s ?p ?o }
}')
            # try a couple of different combos of pagination params
            q.as_pagination_query(1, 20, 0).query.should == 'SELECT * {
  SELECT * {
  SELECT ?s WHERE { ?s ?p ?o }
}
}
LIMIT 20 OFFSET 0'
          end
        end
      end

    end

  end



end
