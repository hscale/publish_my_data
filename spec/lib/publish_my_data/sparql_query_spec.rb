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

  end



end
