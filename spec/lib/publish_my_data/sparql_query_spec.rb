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
    end

    describe '#extract_prefixes' do
      it 'should return the prefixes and query body separately' do
        q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT xyz')
        p, b = q.extract_prefixes
        p.should == 'PREFIX e: <http://example.com>'
        b.should == 'SELECT xyz'
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
          Tripod::SparqlClient::Query.should_receive(:select).with(@query_str, @q.send(:select_format_str)).and_call_original
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
          Tripod::SparqlClient::Query.should_receive(:ask).with(@query_str, @q.send(:ask_format_str)).and_call_original
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
          Tripod::SparqlClient::Query.should_receive(:construct).with(@query_str, @q.send(:construct_or_describe_header)).and_call_original
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
          Tripod::SparqlClient::Query.should_receive(:describe).with(@query_str, @q.send(:construct_or_describe_header)).and_call_original
          @q.execute
        end

        it "should return some data in a SparqlQueryResult object" do
          result = @q.execute
          result.class.should == SparqlQueryResult
          result.to_s.should_not be_blank
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
          q = PublishMyData::SparqlQuery.new(@query_str, :text)
          q.send(:select_format_str).should == "text"
        end
      end

      context "where the request format is json" do
        it "should return 'json'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :json)
          q.send(:select_format_str).should == "json"
        end
      end

      context "where the request format is csv" do
        it "should return 'csv'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :csv)
          q.send(:select_format_str).should == "csv"
        end
      end

      context "where the request format is xml" do
        it "should return 'xml'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :xml)
          q.send(:select_format_str).should == "xml"
        end
      end

      context "where the request format is something random" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :bananas)
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
          q = PublishMyData::SparqlQuery.new(@query_str, :text)
          q.send(:ask_format_str).should == "text"
        end
      end

      context "where the request format is json" do
        it "should return 'json'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :json)
          q.send(:ask_format_str).should == "json"
        end
      end

      context "where the request format is xml" do
        it "should return 'xml'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :xml)
          q.send(:ask_format_str).should == "xml"
        end
      end

      context "where the request format is something random" do
        it "should return 'text'" do
          q = PublishMyData::SparqlQuery.new(@query_str, :bananas)
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
          q = PublishMyData::SparqlQuery.new(@query_str, :ttl)
          q.send(:construct_or_describe_header).should == Mime::TTL
        end
      end

       context "where the request format is rdf" do
        it "should return rdf header" do
          q = PublishMyData::SparqlQuery.new(@query_str, :rdf)
          q.send(:construct_or_describe_header).should == Mime::RDF
        end
      end

      context "where the request format is something random" do
        it "should return ntriples header" do
          q = PublishMyData::SparqlQuery.new(@query_str, :bananas)
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
          }.should raise_error(PublishMyData::SparqlQueryException)
        end
      end

      context "for selects" do
        context 'without prefixes' do
          it "should return a new SparqlQuery with the original query wrapped in a count" do
            q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
            q.as_count_query.class.should == SparqlQuery
            q.as_count_query.query.should == 'SELECT COUNT(*) { SELECT ?s WHERE { ?s ?p ?o } }'
          end
        end

        context 'with prefixes' do
          it "should move the prefixes to the start" do
            q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT ?s WHERE { ?s ?p ?o }')
            q.as_count_query.query.should == 'PREFIX e: <http://example.com> SELECT COUNT(*) { SELECT ?s WHERE { ?s ?p ?o } }'
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
            "vars": [ ".1" ]
          } ,
          "results": {
            "bindings": [
              {
                ".1": { "datatype": "http://www.w3.org/2001/XMLSchema#integer" , "type": "typed-literal" , "value": "2" }
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
          }.should raise_error(PublishMyData::SparqlQueryException)
        end
      end

      context "for selects" do
        context "without prefixes" do

          it "should return a new SparqlQuery with the original query wrapped in a pagination subquery" do
            q = PublishMyData::SparqlQuery.new('SELECT ?s WHERE { ?s ?p ?o }')
            q.as_pagination_query(1, 20, 0).class.should == SparqlQuery
            # try a couple of different combos of pagination params
            q.as_pagination_query(1, 20, 0).query.should == 'SELECT * { SELECT ?s WHERE { ?s ?p ?o } } LIMIT 20 OFFSET 0'
            q.as_pagination_query(1, 20, 1).query.should == 'SELECT * { SELECT ?s WHERE { ?s ?p ?o } } LIMIT 21 OFFSET 0'
            q.as_pagination_query(2, 10, 0).query.should == 'SELECT * { SELECT ?s WHERE { ?s ?p ?o } } LIMIT 10 OFFSET 10'
            q.as_pagination_query(3, 10, 1).query.should == 'SELECT * { SELECT ?s WHERE { ?s ?p ?o } } LIMIT 11 OFFSET 20'
          end
        end

        context "with prefixes" do
          it "should move the prefixes to the start" do
            q = PublishMyData::SparqlQuery.new('PREFIX e: <http://example.com> SELECT ?s WHERE { ?s ?p ?o }')
            q.as_pagination_query(1, 20, 0).query.should == 'PREFIX e: <http://example.com> SELECT * { SELECT ?s WHERE { ?s ?p ?o } } LIMIT 20 OFFSET 0'
          end
        end

        context "with an existing subselect" do
          it "should wrap the select as for a normal select" do
            q = PublishMyData::SparqlQuery.new('SELECT * { SELECT ?s WHERE { ?s ?p ?o } }')
            # try a couple of different combos of pagination params
            q.as_pagination_query(1, 20, 0).query.should == 'SELECT * { SELECT * { SELECT ?s WHERE { ?s ?p ?o } } } LIMIT 20 OFFSET 0'
          end
        end
      end

    end

  end



end
