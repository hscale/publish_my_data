require 'spec_helper'

describe "A visitor navigating straight to the /doc/ page" do

  context "where a resource exists in the database for the corresponding URI" do
    before do
      @resource = FactoryGirl.create(:yuri_unicorn_resource)
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