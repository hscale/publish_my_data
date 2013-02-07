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


  end

end
