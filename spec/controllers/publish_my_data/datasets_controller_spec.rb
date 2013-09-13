require 'spec_helper'

module PublishMyData
  describe DatasetsController do

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

      shared_examples_for "a dataset collection in non-html" do
        it "should render the collection in the right format" do
          get :index, :page => page, :per_page => per_page, :format => format, use_route: :publish_my_data

          q = SparqlQuery.new(Dataset.deprecation_last_query_str).as_pagination_query(page, per_page).query
          datasets_array = Dataset.find_by_sparql(q).to_a

          collection = Tripod::ResourceCollection.new(
            datasets_array,
            :return_graph => false,
            :sparql_query_str => q,
            :resource_class => Dataset
          )

          response.body.should == collection.send("to_#{format}")
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

      shared_examples_for "dataset kaminari pagination" do
        it "should call kaminari to paginate the results" do
          q = SparqlQuery.new(Dataset.deprecation_last_query_str).as_pagination_query(page, per_page).query
          datasets_array = Dataset.find_by_sparql(q).to_a
          count = Dataset.count

          kam = Kaminari.paginate_array(datasets_array, total_count: count)
          Kaminari.should_receive(:paginate_array).with(datasets_array, total_count: count).and_return(kam)
          kam.should_receive(:page).with(page).and_return(kam)
          kam.should_receive(:per).with(per_page).and_return(kam)

          get :index, page: page, per_page: per_page, use_route: :publish_my_data
        end

        it "should set @datasets with the right page of datasets" do
          get :index, page: page, per_page: per_page, use_route: :publish_my_data

          datasets = Dataset.find_by_sparql(Dataset.deprecation_last_query_str)

          assigns['datasets'].map{ |d| d.uri.to_s }.should ==
            datasets[offset...offset+per_page].map{ |d| d.uri.to_s }

          assigns['datasets'].length.should == per_page
        end

      end

      context 'with no pagination params' do
        let(:page) {1}
        let(:per_page) {20}
        let(:offset) { (page-1)*per_page }

        it "should retreive the first page of results" do
          PublishMyData::SparqlQuery.any_instance.should_receive(:as_pagination_query).with(page, per_page)
          get :index, use_route: :publish_my_data
        end

        context 'with html format' do
          it_should_behave_like "dataset kaminari pagination"
        end

        context 'with non-html format' do
          let(:format) {'rdf'}
          it_should_behave_like "a dataset collection in non-html"
        end
      end

      context 'with pagination params' do
        let(:page) {3}
        let(:per_page) {10}
        let(:offset) { (page-1)*per_page }

        it "should retreive the right page of results" do
          PublishMyData::SparqlQuery.any_instance.should_receive(:as_pagination_query).with(page, per_page)
          get :index, page: page, per_page: per_page, use_route: :publish_my_data
        end

        it_should_behave_like "dataset kaminari pagination"

        context 'with non-html format' do
          let(:format) {'ttl'}
          it_should_behave_like "a dataset collection in non-html"
        end
      end

    end

  end
end