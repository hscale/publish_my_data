require 'spec_helper'

describe "A visitor dereferences a uri then asks for a format" do

  before do
    @resource = FactoryGirl.create(:yuri_unicorn_resource)
    visit @resource.uri.to_s
    click_link 'RDF/XML'
  end

  it "should show the right serlialisation, on the doc page url (+format)" do
    page.source.should == @resource.to_rdf
    page.current_url.should == @resource.uri.to_s.sub(/\/id\//,'/doc/') + ".rdf"
  end

end

describe "A visitor dereferences a uri then clicks on a link for another resource" do

  before do
    @yuri = FactoryGirl.create(:yuri_unicorn_resource)
    @boris = FactoryGirl.create(:boris_unicorn_resource)
    @foo_county = FactoryGirl.build(:foreign_resource)
  end

  context "in our domain" do
    before do
      visit @boris.uri.to_s
      click_link "Yuri The Unicorn" # via the knows association
    end

    it "should render the doc page for that uri" do
      page.current_url.should == @yuri.uri.to_s.sub(/\/id\//,'/doc/')
    end
  end

  context "not in our domain" do

    context "where we have data" do
      before do
        @foo_county.save!
        visit @boris.uri.to_s
        click_link @foo_county.label # via the resides-in association
      end
      it "should render the show page for that uri" do
        page.current_url.should == "http://pmdtest.dev/resource?uri=#{CGI.escape(@foo_county.uri.to_s)}"
      end
    end

    context "where we don't have data" do
      before do
        visit @boris.uri.to_s
        click_link @foo_county.uri.to_s # via the resides-in association
      end
      it "should redirect away" do
        page.current_url.should == @foo_county.uri.to_s
      end
    end
  end

end
