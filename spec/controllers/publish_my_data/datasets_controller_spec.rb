require 'spec_helper'

module PublishMyData
  describe DatasetsController do

    describe "#show" do

      context "with an existing dataset slug" do

        let(:dataset) { FactoryGirl.create(:my_dataset) }

        it "should respond successfully" do
          get :show, id: dataset.slug, use_route: :publish_my_data
          response.should be_success
        end
      end

      context "with a non-existent dataset slug" do
        it "should respond successfully" do
          get :show, id: "slug-that-doesnt-exist", use_route: :publish_my_data
          response.should be_not_found
        end
      end

    end

    describe "#index" do

      # make some datasets
      before do
        (1..30).each do |i|
          slug = i
          uri = Dataset.uri_from_slug(slug)
          graph = Dataset.metadata_graph_uri(slug)
          d = PublishMyData::Dataset.new(uri, graph)
          d.title = "Dataset #{i.to_s}"
          d.save!
        end
      end

      shared_examples_for "kaminari pagination" do
        it "should call kaminari to paginate the results" do
          datasets = Dataset.all.limit(per_page).offset(offset).resources
          count = Dataset.count
          kam = Kaminari.paginate_array(datasets, total_count: @count)

          Kaminari.should_receive(:paginate_array).with(datasets, total_count: count).and_return(kam)
          kam.should_receive(:page).with(page).and_return(kam)
          kam.should_receive(:per).with(per_page).and_return(kam)
          get :index, _page: page, _per_page: per_page, use_route: :publish_my_data
        end

        it "should set @datasets with the right page of datasets" do
          get :index, _page: page, _per_page: per_page, use_route: :publish_my_data
          assigns['datasets'].map{ |d| d.uri.to_s }.should == Dataset.all.resources[offset...offset+per_page].map{ |d| d.uri.to_s }
          assigns['datasets'].length.should == per_page
        end

        it "should set @count with the total count" do
          get :index, _page: page, _per_page: per_page, use_route: :publish_my_data
          assigns['count'].should == Dataset.count
        end
      end


      context 'with no pagination params' do
        let(:page) {1}
        let(:per_page) {20}
        let(:offset) { (page-1)*per_page }

        it "should retreive the first page of results" do
          crit = Dataset.all
          Dataset.should_receive(:all).at_least(:once).and_return(crit)
          crit.should_receive(:limit).with(per_page).and_call_original
          crit.should_receive(:offset).with(offset).and_call_original
          get :index, use_route: :publish_my_data
        end

        it_should_behave_like "kaminari pagination"
      end

      context 'with pagination params' do
        let(:page) {3}
        let(:per_page) {10}
        let(:offset) { (page-1)*per_page }

        it "should retreive the right page of results" do
          crit = Dataset.all
          Dataset.should_receive(:all).at_least(:once).and_return(crit)
          crit.should_receive(:limit).with(per_page).and_call_original
          crit.should_receive(:offset).with(offset).and_call_original
          get :index, _page: page, _per_page: per_page, use_route: :publish_my_data
        end

        it_should_behave_like "kaminari pagination"

      end

    end

  end
end