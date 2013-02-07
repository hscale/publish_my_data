require 'spec_helper'

describe "A visitor viewing a resource not in our domain" do

  before do
    @foreign_resource = FactoryGirl.build(:foreign_resource)
    @url = "http://pmdtest.dev/resource?uri=#{CGI.escape(@foreign_resource.uri.to_s)}"
  end

  context 'where we have data about it' do

    before do
      @foreign_resource.save!
    end

    it "should show a page about that resource" do
      visit @url
      page.current_url.should eq(@url)
      page.should have_content @foreign_resource.uri.to_s
    end
  end

  context "where we don't have data about it" do

    it "should redirect away" do
      visit @url
      page.current_url.should eq(@foreign_resource.uri.to_s)
    end
  end

end