require 'spec_helper'

# TO TEST:
# pagination
# other formats direct - including errors.

describe 'visiting the sparql endpoint' do

  shared_examples_for 'a non-html error' do
    it "should 400 with a blank response" do
      page.source.should be_blank
      page.status_code.should == 400
    end
  end

  shared_examples_for 'a sparql query' do
    it "should show the results in the page" do
      page.should have_content PublishMyData::SparqlQuery.new(@query).execute.to_s
    end
  end

  shared_examples_for "a json response" do
    it 'should render json' do
      page.source.should ==  PublishMyData::SparqlQuery.new(@query, :json).execute.to_s
    end
  end

  shared_examples_for "an xml response" do
    it 'should render xml' do
      page.source.should ==  PublishMyData::SparqlQuery.new(@query, :xml).execute.to_s
    end
  end

  shared_examples_for "an rdf response" do
    it 'should render rdf' do
      page.source.should ==  PublishMyData::SparqlQuery.new(@query, :rdf).execute.to_s
    end
  end

  shared_examples_for "a csv response" do
    it 'should render csv' do
      page.source.should ==  PublishMyData::SparqlQuery.new(@query, :csv).execute.to_s
    end
  end

  shared_examples_for "a text response" do
    it 'should render text' do
      page.source.should ==  PublishMyData::SparqlQuery.new(@query, :text).execute.to_s
    end
  end

  shared_examples_for "an n-triples response" do
    it 'should render ntriples' do
      page.source.should ==  PublishMyData::SparqlQuery.new(@query, :nt).execute.to_s
    end
  end

  shared_examples_for "a turtle response" do
    it 'should render turtle' do
      page.source.should ==  PublishMyData::SparqlQuery.new(@query, :ttl).execute.to_s
    end
  end

  shared_examples_for 'a construct query' do
    describe 'and clicks N-triples format' do
      before { page.click_link "N-triples" }

      it_should_behave_like "an n-triples response"
    end

    describe 'and clicks Turtle format' do
      before { page.click_link "Turtle" }

      it_should_behave_like "a turtle response"
    end

    describe 'and clicks rdf/xml format' do
      before { page.click_link "RDF/XML" }

      it_should_behave_like "an rdf response"
    end
  end

  before do
    @yuri = FactoryGirl.create(:yuri_unicorn_resource)
    @boris = FactoryGirl.create(:boris_unicorn_resource)
    visit '/sparql'
  end

  describe "and runs a sparql construct" do
    before do
      @query = 'construct {?s ?p ?o} where {?s ?p ?o}'
      page.fill_in 'query', with: @query
      find('form input[type="submit"]').click
    end

    it_should_behave_like 'a sparql query'

    it_should_behave_like 'a construct query'
  end

  describe "and runs a sparql describe" do
    before do
      @query = "Describe <#{@yuri.uri.to_s}>"
      page.fill_in 'query', with: @query
      find('form input[type="submit"]').click
    end

    it_should_behave_like 'a sparql query'

    it_should_behave_like 'a construct query'
  end

  describe "and runs a sparql ask" do
    before do
      @query = "ASK where {?s ?p ?o}"
      page.fill_in 'query', with: @query
      find('form input[type="submit"]').click
    end

    describe 'and clicks JSON format' do
      before { page.click_link "JSON" }

      it_should_behave_like 'a json response'
    end

    describe 'and clicks XML format' do
      before { page.click_link "XML" }

      it_should_behave_like 'an xml response'
    end

    describe 'and clicks Text format' do
      before { page.click_link "Text" }

      it_should_behave_like 'a text response'
    end

  end

  describe "and runs a sparql select" do

    before do
      @query = 'select * where {?s ?p ?o}'
      page.fill_in 'query', with: @query
      find('form input[type="submit"]').click
    end

    it_should_behave_like 'a sparql query'

    describe 'and clicks XML format' do
      before { page.click_link "XML" }

      it_should_behave_like 'an xml response'
    end

    describe 'and clicks CSV format' do
      before { page.click_link "CSV" }

      it_should_behave_like 'a csv response'
    end

    describe 'and clicks JSON format' do
      before { page.click_link "JSON" }

      it_should_behave_like 'a json response'
    end

    describe 'and clicks Text format' do
      before { page.click_link "Text" }

      it_should_behave_like 'a text response'
    end

  end

  describe "and runs an unknown query type" do

    before do
      @query = 'MUNGE * where {?s ?p ?o}'
      page.fill_in 'query', with: @query
      find('form input[type="submit"]').click
    end

    it "should show a message" do
      page.should have_content "Unsupported Query Type."
    end
  end

  describe "and runs a query with a large response" do
    before do
      PublishMyData::SparqlQueryResult.any_instance.should_receive(:length).at_least(:once).and_return(10.megabytes)
      @query = 'CONSTRUCT {?s ?p ?o} where {?s ?p ?o}'
      page.fill_in 'query', with: @query
      find('form input[type="submit"]').click
    end

    it "should show a message" do
      page.should have_content "The results for this query are too large to return."
    end
  end

  describe "and runs a query with a syntax error" do
    before do
      @query = 'SELECT * where ?s ?p ?o}'
      page.fill_in 'query', with: @query
      find('form input[type="submit"]').click
    end

    it "should show the message from Fuseki" do

    end
  end

end

describe "calling a sparql query programmatically (non-html)" do

  context "with a valid query" do
    before do
      @query = 'select * where {?s ?p ?o}'
    end

    context "for a relevant format" do
      before do
        page.driver.header 'Accept','application/json'
        visit "/sparql?query=#{URI.encode(@query)}"
      end

      it_should_behave_like "a json response"
    end

    context "for an invalid format for this query type" do
      before do
        page.driver.header 'Accept','application/n-triples'
        visit "/sparql?query=#{URI.encode(@query)}"
      end

      it 'should render the default (in this case "text")' do
        page.source.should ==  PublishMyData::SparqlQuery.new(@query, :text).execute.to_s
      end

    end
  end

  context "with an unknown query type" do
    before do
      @query = 'MUNGE * where {?s ?p ?o}'
      page.driver.header 'Accept','text/plain'
      visit "/sparql?query=#{URI.encode(@query)}"
    end

    it_should_behave_like 'a non-html error'
  end

  describe "and runs a query with a syntax error" do
    before do
      @query = 'SELECT * where ?s ?p ?o}'
      page.driver.header 'Accept','text/plain'
      visit "/sparql?query=#{URI.encode(@query)}"
    end

    it_should_behave_like 'a non-html error'

  end



end
