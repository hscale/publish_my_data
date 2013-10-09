# UUID_REGEX = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/

require 'spec_helper'

include PublishMyData

feature "Preparing a Stats Selector document" do
  let(:selector) { Statistics::Selector.create(
    id: '12345678-abcd-efab-1234-5678abcdefab',
    geography_type: 'http://statistics.data.gov.uk/def/statistical-geography',
    row_uris: ['http://statistics.data.gov.uk/id/statistical-geography/E07000008', 'http://statistics.data.gov.uk/id/statistical-geography/E07000036']
  ) }
  let(:dataset)  { FactoryGirl.create(:dataset) }

  describe "Previewing data for a selector" do
    background do
      GeographyTasks.create_some_gss_resources
    end

    scenario 'Visitor uploads a file containing a mix of GSS codes and other text' do
      visit '/selectors/new'
      attach_file 'csv_upload', File.expand_path('spec/support/gss_etc.csv')
      click_on 'Upload'

      page.should have_content 'Step 2 of 3: Review the data'
      page.should have_content '2 GSS codes imported'
      page.should have_content '3 rows not imported'
      find('#non-imported-data').should have_content 'Ham'
      find('#non-imported-data').should have_content 'Beans'
      find('#non-imported-data').should have_content 'Eggs'
    end

    scenario 'Visitor uploads an animal gif' do
      visit '/selectors/new'
      attach_file 'csv_upload', File.expand_path('spec/support/dog.gif')
      click_on 'Upload'

      page.should have_content 'Step 1 of 3: Upload GSS Codes'
      page.should have_content 'The uploaded file did not contain valid CSV data'
    end

    scenario 'Visitor uploads a file containing GSS codes at both LA and LSOA level' do
      visit '/selectors/new'
      attach_file 'csv_upload', File.expand_path('spec/support/gss_mixed.csv')
      click_on 'Upload'

      page.should have_content 'Step 1 of 3: Upload GSS Codes'
      page.should have_content 'The uploaded file should contain GSS codes at either LSOA or Local Authority level.'
    end
  end

  describe 'Creating a new Selector' do
    background do
      GeographyTasks.create_some_gss_resources

      visit '/selectors/new'
      attach_file 'csv_upload', File.expand_path('spec/support/gss_etc.csv')
      click_on 'Upload'
    end

    scenario 'Accepting the preview and creating a selector' do
      click_on 'Proceed to next step'

      page.should have_content 'Step 3 of 3: Add column data'
      page.should have_content 'E07000008 Cambridge'
      page.should have_content 'E07000036 Erewash'
    end
  end

  describe 'Selecting a dataset', js: true do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)
    end

    scenario 'Visitor selects a dataset from which to create a fragment' do
      visit "/selectors/#{selector.id}"
      click_on 'Add Data'

      page.should have_content 'Step 1 of 2: Select a Dataset'

      select dataset.title, from: 'dataset_uri'
      click_on 'Select Dataset'

      page.should have_content 'Step 2 of 2: Filter data'
      page.should have_content dataset.title
    end
  end

  describe 'Selecting some dimension filters for a dataset', js: true do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)

      visit "/selectors/#{selector.id}"
      click_on 'Add Data'
      select dataset.title, from: 'dataset_uri'
      click_on 'Select Dataset'
    end

    scenario 'Visitor selects a dimension filter, leaving another open' do
      click_on '2013 Q1'

      page.should have_content 'Filtered by'
      page.should have_content 'All Ethnicities'
      # filter should have moved from the list of options to the list of applied filters
      find('#filters').should have_content '2013 Q1'
      find('#filter-options').should_not have_content '2013 Q1'
    end

    scenario 'Visitor selects a dimension filter, then unselects it' do
      click_on '2013 Q1'
      find('#filters').should have_content '2013 Q1'
      find('#filter-options').should_not have_content '2013 Q1'

      find('#filters').click_link '×'
      page.should have_content 'All possible combinations of dataset dimension are currently chosen'
      page.should_not have_css('#filters')
      find('#filter-options').should have_content '2013 Q1'
    end
  end

  describe 'Creating a fragment', js: true do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)

      visit "/selectors/#{selector.id}"
      click_on 'Add Data'
      select dataset.title, from: 'dataset_uri'
      click_on 'Select Dataset'
    end

    context '... filtering on all dimensions' do
      background do
        click_on '2013 Q1'
        click_on 'Mixed'
      end

      scenario 'Visitor completes the fragment creation process' do
        click_on 'Add 1 column of data'

        page.should have_content 'Step 3 of 3: Add column data'
        page.should have_content '2013 Q1'
        page.should have_content 'Mixed'
        # page.should have_content '234'
        # page.should have_content '2345'
      end
    end

    context '... filtering on a single dimensions' do
      background do
        click_on '2013 Q1'
      end

      scenario 'Visitor completes the fragment creation process' do
        click_on 'Add 3 columns of data'

        page.should have_content 'Step 3 of 3: Add column data'
        page.should have_content 'White'
        page.should have_content 'Mixed'
        page.should have_content 'Black' # all values for unfiltered dimension are present
      end
    end
  end

  describe 'removing a fragment' do
    background do
      GeographyTasks.create_some_gss_resources
      GeographyTasks.create_relevant_vocabularies
      GeographyTasks.populate_dataset_with_geographical_observations(dataset)

      selector.build_fragment(dataset_uri: dataset.uri, dimensions: [
        { dimension_uri: 'http://opendatacommunities.org/def/ontology/time/refPeriod', dimension_values: ['http://reference.data.gov.uk/id/quarter/2013-Q1'] },
        { dimension_uri: 'http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/ethnicity', dimension_values: ['http://opendatacommunities.org/def/concept/general-concepts/ethnicity/mixed'] }
      ])
      selector.save

      visit "/selectors/#{selector.id}"
    end

    scenario 'Visitor removes some data from the selector', js: true do
      find('th.fragment-actions').trigger(:mouseover)
      find('th.fragment-actions').click_link '×'
      page.should_not have_content '2013 Q1'
    end
  end
end