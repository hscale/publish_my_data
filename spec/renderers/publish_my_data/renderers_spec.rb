require 'spec_helper'

module PublishMyData

  describe "::ActionController" do
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
  end

end