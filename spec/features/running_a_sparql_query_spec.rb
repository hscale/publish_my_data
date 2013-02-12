require 'spec_helper'

# TO TEST:
# large responses
# pagination
# format links



describe "A visitor visits the endpoint and runs a sparql select" do

  # load some data
  before do
    @yuri = FactoryGirl.create(:yuri_unicorn_resource)
    @boris = FactoryGirl.create(:boris_unicorn_resource)
    @query = 'select * where {?s ?p ?o}'

    visit '/sparql'
    page.fill_in 'query', with: @query
    find('form input[type="submit"]').click
  end

  it "should show the results in the page" do
    page.should have_content PublishMyData::SparqlQuery.new(@query).execute.to_s
  end


end

