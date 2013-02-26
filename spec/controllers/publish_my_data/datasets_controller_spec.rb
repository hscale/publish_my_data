require 'spec_helper'

module PublishMyData
  describe DatasetsController do

    describe "#show" do

      let(:dataset) { FactoryGirl.create(:my_dataset) }

      shared_examples_for "dataset show" do

        context "for an existing dataset" do
          it "should respond successfully" do
            get :show, id: dataset.slug, use_route: :publish_my_data, :format => format
            response.should be_success
          end
        end

        context "with a non-existent dataset slug" do
          it "should respond with not found" do
            get :show, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
            response.should be_not_found
          end
        end
      end

      shared_examples_for "a non html format" do

        context "for an existing dataset" do
          it "should return the dataset dtls in that format" do
            get :show, id: dataset.slug, use_route: :publish_my_data, :format => format
            response.body.should == dataset.send("to_#{format}")
          end
        end

        context "for a non-existent dataset slug" do
          it "should return a blank body" do
            get :show, id: "slug-that-doesnt-exist", use_route: :publish_my_data, :format => format
            response.body.should be_blank
          end
        end
      end

      context "for rdf format" do
        let(:format){ 'html' }
        it_should_behave_like "dataset show"
      end

      context "for rdf format" do
        let(:format){ 'rdf' }
        it_should_behave_like "a non html format"
        it_should_behave_like "dataset show"
      end

      context "for json format" do
        let(:format){ 'json' }
        it_should_behave_like "a non html format"
        it_should_behave_like "dataset show"
      end

      context "for ttl format" do
        let(:format){ 'ttl' }
        it_should_behave_like "a non html format"
        it_should_behave_like "dataset show"
      end

      context "for ntriples format" do
        let(:format){ 'nt' }
        it_should_behave_like "a non html format"
        it_should_behave_like "dataset show"
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
          d.theme = (i.even? ? 'theme' : 'othertheme')
          d.save!
        end
      end

      shared_examples_for "a collection in non-html" do
        it "should render the collection in the right format" do
          get :index, :page => page, :per_page => per_page, :format => format, use_route: :publish_my_data
          response.body.should == Dataset.all.limit(per_page).offset(offset).resources.send("to_#{format}")
        end

        it "shouldn't call Kaminari" do
          Kaminari.should_not_receive(:paginate_array)
          get :index, :page => page, :per_page => per_page, :format => format, use_route: :publish_my_data
        end

        it "should render successfully" do
          get :index, :page => page, :per_page => per_page, :format => format, use_route: :publish_my_data
          response.should be_success
        end
      end

      shared_examples_for "kaminari pagination" do
        it "should call kaminari to paginate the results" do
          datasets_array = Dataset.all.limit(per_page).offset(offset).resources.to_a
          count = Dataset.count

          kam = Kaminari.paginate_array(datasets_array, total_count: count)

          Kaminari.should_receive(:paginate_array).with(datasets_array, total_count: count).and_return(kam)
          kam.should_receive(:page).with(page).and_return(kam)
          kam.should_receive(:per).with(per_page).and_return(kam)
          get :index, page: page, per_page: per_page, use_route: :publish_my_data
        end

        it "should set @datasets with the right page of datasets" do
          get :index, page: page, per_page: per_page, use_route: :publish_my_data
          assigns['datasets'].map{ |d| d.uri.to_s }.should ==
            Dataset.all.resources[offset...offset+per_page].map{ |d| d.uri.to_s }
          assigns['datasets'].length.should == per_page
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

        context 'with html format' do
          it_should_behave_like "kaminari pagination"
        end

        context 'with non-html format' do
          let(:format) {'rdf'}
          it_should_behave_like "a collection in non-html"
        end
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
          get :index, page: page, per_page: per_page, use_route: :publish_my_data
        end

        it_should_behave_like "kaminari pagination"

        context 'with non-html format' do
          let(:format) {'ttl'}
          it_should_behave_like "a collection in non-html"
        end
      end

      context "with a theme parameter" do
        let(:theme) {'theme'}

        it "should filter the results to only datasets in the theme" do
          get :index, theme: theme, use_route: :publish_my_data
          assigns['datasets'].length.should == 15 # only the even ones are in this theme
        end
      end

    end

  end
end