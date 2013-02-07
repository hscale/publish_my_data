require 'spec_helper'

describe "A visitor dereferences a uri then asks for a format" do

  before do
    @resource = FactoryGirl.create(:unicorn_resource)
    visit @resource.uri.to_s
    click_link 'RDF/XML'
  end

  it "should show the right serlialisation, on the doc page url (+format)" do
    page.source.should == @resource.to_rdf
    page.current_url.should == @resource.uri.to_s.sub(/\/id\//,'/doc/') + ".rdf"
  end

end

describe "A visitor dereferences a uri then clicks on a link for another resource in our domain" do
  it "should render the doc page for that uri"
end

describe "A visitor dereferences a uri then clicks on a link for a resource not in our domain" do
  context "where we have data" do
    it "should render the show page for that uri"
  end

  context "where we don't have data" do
    it "show redirect away"
  end
end