require 'spec_helper'

describe "A visitor dereferencing a URI" do

  context "where a resource exists in the database for that URI" do
    before do
      @resource = FactoryGirl.create(:unicorn_resource)
    end

    context 'for HTML format' do
      it "should redirect to the doc page for that URI" do
        visit @resource.uri.to_s
        page.current_url.should eq('http://pmdtest.dev/doc/unicorns/yuri')
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
        page.should have_content 'Not found'
      end

    end

    context 'for data format' do
      before do
        page.driver.header 'Accept','application/rdf+xml'
      end

      it "should 404, with blank response" do
        visit 'http://pmdtest.dev/foo/'
        page.status_code.should == 404
        page.source.should be_blank
      end
    end

  end

end

describe "A visitor navigating straight to the /doc/ page" do

  context "where a resource exists in the database for the corresponding URI" do
    before do
      @resource = FactoryGirl.create(:unicorn_resource)
    end

    context 'for HTML format' do

      it "should render the doc page succesfully" do
        visit @resource.uri.to_s.sub(/\/id\//,'/doc/')
        page.should have_content @resource.uri.to_s
      end

    end

    context 'for JSON format' do

      context 'with accept header' do

        before do
          page.driver.header 'Accept','application/json'
        end

        it 'should respond with JSON' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/')
          page.source.should == @resource.to_json
        end

      end

      context 'with format extension' do

        it 'should respond with JSON' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/') + '.json'
          page.source.should == @resource.to_json
        end

      end

    end

    context 'for turtle format' do

      context 'with accept header' do

        before do
          page.driver.header 'Accept','text/turtle'
        end

        it 'should respond with turtle' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/')
          page.source.should == @resource.to_ttl
        end

      end

      context 'with format extension' do

        it 'should respond with turtle' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/') + '.ttl'
          page.source.should == @resource.to_ttl
        end

      end

    end

    context 'for n-triples format' do

      context 'with accept header' do

        before do
          page.driver.header 'Accept','application/n-triples'
        end

        it 'should respond with n-triples' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/')
          page.source.should == @resource.to_nt
        end

      end

      context 'with format extension' do

        it 'should respond with turtle' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/') + '.nt'
          page.source.should == @resource.to_nt
        end

      end

    end

    context 'for rdf/xml format' do

      context 'with accept header' do

        before do
          page.driver.header 'Accept','application/rdf+xml'
        end

        it 'should respond with rdf' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/')
          page.source.should == @resource.to_rdf
        end

      end

      context 'with format extension' do

        it 'should respond with rdf' do
          visit @resource.uri.to_s.sub(/\/id\//,'/doc/') + '.rdf'
          page.source.should == @resource.to_rdf
        end

      end

    end

  end

end