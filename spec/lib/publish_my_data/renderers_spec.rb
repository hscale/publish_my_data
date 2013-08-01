require 'spec_helper'

module PublishMyData

  describe "::ActionController" do

    ## symbol to string lookups
    it "should match :ttl to the right mime type" do
      Mime::TTL.to_sym.should == :ttl
      Mime::TTL.to_s.should == "text/turtle"
    end

    it "should match :rdf to the right mime type" do
      Mime::RDF.to_sym.should == :rdf
      Mime::RDF.to_s.should == "application/rdf+xml"
    end

    it "should match :nt to the right mime type" do
      Mime::NT.to_sym.should == :nt
      Mime::NT.to_s.should == "application/n-triples"
    end

    it "should match :json to the right mime type" do
      Mime::JSON.to_sym.should == :json
      Mime::JSON.to_s.should == "application/json"
    end

    it "should match :xml to the right mime type" do
      Mime::XML.to_sym.should == :xml
      Mime::XML.to_s.should == "application/xml"
    end

    it "should match :text to the right mime type" do
      Mime::TEXT.to_sym.should == :text
      Mime::TEXT.to_s.should == "text/plain"
    end

    it "should match :csv to the right mime type" do
      Mime::CSV.to_sym.should == :csv
      Mime::CSV.to_s.should == "text/csv"
    end

    ## string to symbol lookups

    it "should match 'text/turtle' to the right mime type" do
      Mime::Type.lookup('text/turtle').should == Mime::TTL
    end

    it "should match 'text/turtle' to the right mime type" do
      Mime::Type.lookup('application/rdf+xml').should == Mime::RDF
    end

    it "should match 'text/turtle' to the right mime type" do
      Mime::Type.lookup('application/n-triples').should == Mime::NT
    end

    it "should match 'text/plain' to the right mime type" do
      Mime::Type.lookup('text/plain').should == Mime::TEXT
    end

    it "should match 'application/sparql+json' to the right mime type" do
      Mime::Type.lookup('application/sparql-results+json').should == Mime::JSON
    end

    it "should match 'application/json' to the right mime type" do
      Mime::Type.lookup('application/json').should == Mime::JSON
    end

    it "should match 'application/sparql+xml' to the right mime type" do
      Mime::Type.lookup('application/sparql-results+xml').should == Mime::XML
    end

     it "should match 'application/xml' to the right mime type" do
      Mime::Type.lookup('application/xml').should == Mime::XML
    end

  end

end