require 'spec_helper'

module PublishMyData
  describe ThemesController do

    let(:theme) { FactoryGirl.create(:my_theme) }

    before do

      # datasets in our theme
      (1..21).each do |i|
        slug = i
        uri = Dataset.uri_from_slug(slug)
        graph = Dataset.metadata_graph_uri(slug)
        d = PublishMyData::Dataset.new(uri, graph)
        d.theme = theme.uri
        d.title = "Dataset #{i.to_s}"
        d.save!
      end

      # some more themes
      (1..5).each do |i|
        slug = "theme-#{i}"
        uri = "http://#{PublishMyData.local_domain}/def/theme/#{slug}"
        t = PublishMyData::Theme.new(uri)
        t.slug = slug
        t.label = "Theme #{i}"
        t.comment = "A theme"
        t.save!
      end

    end

    describe "#show" do
      context "with html format" do

        context "for an existing theme" do
          it "should respond successfully" do
            get :show, :id => theme.slug, :use_route => :publish_my_data
            response.should be_success
          end
        end

        context "for a non existent theme" do
          it "should respond with not found" do
            get :show, :id => "theme-that-doesnt-exist", :use_route => :publish_my_data
            response.should be_not_found
          end
        end
      end

      context "with a non-html format" do
        it "should respond with the paginated collection of datasets in that theme" do
          get :show, :id => theme.slug, :use_route => :publish_my_data, :format => 'ttl', :per_page => 5
          pagination_params = PaginationParams.from_request(@request)
          paginator = Paginator.new(theme.datasets_criteria, PaginationParams.from_request(@request))
          paginator.paginate.length.should == 5 #just the page's worth
          response.body.should == paginator.paginate.to_ttl
        end

        context "for a non existent theme" do
          it "should respond with not found" do
            get :show, :id => "theme-that-doesnt-exist", :use_route => :publish_my_data, :format => 'rdf'
            response.should be_not_found
          end

          it "should respond with an empty body" do
            get :show, :id => "theme-that-doesnt-exist", :use_route => :publish_my_data, :format => 'rdf'
            response.body.strip.should be_blank
          end
        end
      end
    end

    describe "#index" do
      context "with html format" do
        it "should respond successfully" do
          get :index, :use_route => :publish_my_data
          response.should be_success
        end

        it "should set the themes variable" do
          get :index, :use_route => :publish_my_data
          assigns['themes'].should_not be_nil
        end

        it 'should set the themes variable to all themes' do
          get :index, :use_route => :publish_my_data
          assigns['themes'].should == Theme.all.resources
          assigns['themes'].length.should == 6 # our list plus the my-theme one
        end
      end

      context 'with a non-html format' do

        it 'should respond successfully' do
          get :index, :format => 'ttl', :use_route => :publish_my_data
          response.should be_success
        end

        it 'should respond with the data in the right format' do
          get :index, :format => 'ttl', :use_route => :publish_my_data
          response.body.should == Theme.all.resources.to_ttl
        end
      end
    end

  end

end