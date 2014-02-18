require 'spec_helper'

describe "A visitor dereferencing a URI" do

  context "where a resource exists in the database for that URI" do
    before do
      @resource = FactoryGirl.create(:yuri_unicorn_resource)
    end

    context 'for HTML format' do
      it "should redirect to the doc page for that URI" do
        visit @resource.uri.to_s
        page.current_url.should == @resource.uri.to_s.sub(/\/id\//,'/doc/')
        page.should have_content @resource.uri.to_s
      end
    end

    context 'with a JSON accept header' do
      before do
        page.driver.header 'Accept','application/json'
      end

      it "should return the json serialisation of the resource" do
        visit @resource.uri.to_s
        page.source.should == @resource.to_json
      end
    end

    context 'with a turtle accept header' do
      before do
         page.driver.header 'Accept','text/turtle'
      end

      it "should return the turtle serialisation of the resource" do
        visit @resource.uri.to_s
        page.source.should == @resource.to_ttl
      end
    end

    context 'with an n-triples accept header' do
      before do
        page.driver.header 'Accept','application/n-triples'
      end

      it "should return the ntriples serialisation of the resource" do
        visit @resource.uri.to_s
        page.source.should == @resource.to_nt
      end
    end

    context 'with an RDF/XML accept header' do
      before do
        page.driver.header 'Accept','application/rdf+xml'
      end

      it "should return the rdf serialisation of the resource" do
        visit @resource.uri.to_s
        page.source.should == @resource.to_rdf
      end
    end
  end

  context "where a resource doesn't exist in the database for that URI" do

    context 'for HTML format' do

      it "should render the 404 page with the right status" do
        visit 'http://pmdtest.dev/foo/'
        page.status_code.should == 404
        page.should have_content 'Resource not found'
      end

    end

    context 'for data format' do
      before do
        page.driver.header 'Accept','application/rdf+xml'
      end

      it "should 404, with blank response" do
        visit 'http://pmdtest.dev/foo/'
        page.status_code.should == 404
        page.source.should == "Not Found"
      end
    end

  end

end