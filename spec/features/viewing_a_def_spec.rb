require 'spec_helper'

describe "A visitor viewing a def" do

  context "where a resource exists in the database for that URI" do
    before do
      @resource = FactoryGirl.create(:mean_result)
    end

    context 'for HTML format' do
      it "should render a page about it (no redirect)" do
        visit @resource.uri.to_s
        page.current_url.should eq(@resource.uri.to_s)
        page.should have_content @resource.uri.to_s
      end
    end

    context 'for an alternative format' do

      context 'with accept header' do

        before do
          page.driver.header 'Accept','application/n-triples'
        end

        it 'should respond with the right format' do
          visit @resource.uri.to_s
          page.source.should == @resource.to_nt
        end

      end

      context 'with format extension' do

        it 'should respond with the right format' do
          visit @resource.uri.to_s + '.rdf'
          page.source.should == @resource.to_rdf
        end

      end

    end

  end
end