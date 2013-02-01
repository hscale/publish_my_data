require 'spec_helper'

module PublishMyData
  describe Resource do

    describe ".uri_from_host_and_doc_path" do

      context "with no format" do
        it "should return the uri formed from the host doc path" do
          Resource.uri_from_host_and_doc_path('example.com', 'hello/jello').should == 'http://example.com/id/hello/jello'
        end
      end

      context "with a format" do
        it "should return the uri formed from the host doc path, with the format stripped off" do
          Resource.uri_from_host_and_doc_path('example.com', 'hello/jello.rdf', 'rdf').should == 'http://example.com/id/hello/jello'
        end
      end

    end

  end
end