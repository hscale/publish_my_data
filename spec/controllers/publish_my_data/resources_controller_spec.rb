require 'spec_helper'

module PublishMyData
  describe ResourcesController do

    describe "#id" do

      context "with html mime type" do

        before do
          get :id, :path => "this/is/my/path", use_route: :publish_my_data
        end

        it "should redirect to the corresponding doc view with a 303" do
          response.status.should eq(303)
          response.should redirect_to "/doc/this/is/my/path"
        end
      end

      context "with an alternative mime type passed in the header" do
        before do
          @request.env['HTTP_ACCEPT'] = "application/rdf+xml"
          get :id, :path => "this/is/my/path", use_route: :publish_my_data
        end

        it "should keep that mime type when doing the 303" do
          response.status.should eq(303)
          response.should redirect_to "/doc/this/is/my/path"
          response.content_type.should == Mime::RDF
        end
      end

    end

    describe "#doc" do

      before do
        @resource = FactoryGirl.create(:yuri_unicorn_resource)
      end

      it "should respond successfully" do
        get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        response.should be_success
      end

      it "should render the doc template" do
        get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        response.should render_template("publish_my_data/resources/doc")
      end

      context "for html" do
        it "should eager load the labels" do
          Resource.should_receive(:find).and_return(@resource)
          @resource.should_receive(:eager_load_predicate_triples!)
          @resource.should_receive(:eager_load_object_triples!)
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end
      end

      context "with an alternative mime type passed in the header" do

        before do
          @request.env['HTTP_ACCEPT'] = "application/rdf+xml"
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        it "should resond with the right mime type" do
          response.content_type.should == Mime::RDF
        end

        it "should respond with the right content" do
          response.body.should == @resource.to_rdf
        end

        it "should not eager load the labels" do
          Resource.should_receive(:find).and_return(@resource)
          @resource.should_not_receive(:eager_load_predicate_triples!)
          @resource.should_not_receive(:eager_load_object_triples!)
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        context "and the resource doesn't exist" do
          it "should 404 with a blank response" do
            get :doc, :path => "unicorns/borat", use_route: :publish_my_data
            response.should be_not_found
            response.body.should be_blank
          end
        end

      end

      context "with an alternative format passed on the url" do

        it "should resond with the right mime type" do
          get :doc, :path => "unicorns/yuri", format: 'ttl', use_route: :publish_my_data
          response.content_type.should == Mime::TTL
        end

        it "should respond with the right content" do
          get :doc, :path => "unicorns/yuri", format: 'ttl', use_route: :publish_my_data
          response.body.should == @resource.to_ttl
        end

      end

      context "when resource doesn't exist" do

        before do
          get :doc, :path => "doesnt/exist", use_route: :publish_my_data
        end

        it "should 404" do
          response.should be_not_found
        end

      end

    end

    describe "#definition" do

      before do
        @resource = FactoryGirl.create(:mean_result)
      end

      context "for resource in our database" do

        it "should respond successfully" do
          get :definition, :path => "statistics/meanResult", use_route: :publish_my_data
          response.should be_success
        end

        it "should render the doc template" do
          get :definition, :path => "statistics/meanResult", use_route: :publish_my_data
          response.should render_template("publish_my_data/resources/doc")
        end

        context "with an alternative mime type" do
          it "should with the right mime type and content" do
            get :definition, :path => "statistics/meanResult", :format => 'nt', use_route: :publish_my_data
            response.content_type.should == Mime::NT
            response.body.should == @resource.to_nt
          end
        end

      end

      context "when resource doesn't exist" do
        it "should 404" do
          get :definition, :path => "statistics/nonExistent", use_route: :publish_my_data
          response.should be_not_found
        end
      end

    end

    describe "#show" do

      context "with a resource not in our database" do

        uri = "http://purl.org/linked-data/sdmx/2009/dimension%23refArea"

        context "html mime type" do

          before do
            get :show, :uri => uri, use_route: :publish_my_data
          end

          context "with resource not in our database" do
            it "should redirect to the external uri" do
              response.should redirect_to('http://purl.org/linked-data/sdmx/2009/dimension%23refArea')
            end
          end

        end

        context "non html mime type" do

          before do
            get :show, :uri => uri, :format => 'rdf', use_route: :publish_my_data
          end

          it "should 404" do
            response.should be_not_found
          end
        end
      end

      context "with a resource in our database" do

        before do
          uri = 'http://uri'
          graph = 'http://graph'
          r = Resource.new(uri, graph)
          r.write_predicate('http://foo', 'blah')
          r.save!

          get :show, :uri => r.uri, use_route: :publish_my_data
        end

        it "should respond succesfully" do
          response.should be_success
        end

        it "should render the show template" do
          response.should render_template("publish_my_data/resources/show")
        end

      end
    end

    describe "#index" do

       shared_examples_for "kaminari pagination" do
        it "should call kaminari to paginate the results" do
          res_array = Resource.all.limit(per_page).offset(offset).resources.to_a
          count = Resource.count

          kam = Kaminari.paginate_array(res_array, total_count: count)

          Kaminari.should_receive(:paginate_array).with(res_array, total_count: count).and_return(kam)
          kam.should_receive(:page).with(page).and_return(kam)
          kam.should_receive(:per).with(per_page).and_return(kam)
          get :index, page: page, per_page: per_page, use_route: :publish_my_data
        end

        it "should set @resources with the right page of datasets" do
          get :index, page: page, per_page: per_page, use_route: :publish_my_data
          assigns['resources'].map{ |d| d.uri.to_s }.should ==
            Resource.all.resources[offset...offset+per_page].map{ |r| r.uri.to_s }
          assigns['resources'].length.should == per_page
        end
      end

      shared_examples_for "a collection in non-html" do
        it "should render the collection in the right format" do
          get :index, :page => page, :per_page => per_page, :format => format, use_route: :publish_my_data
          response.body.should == Resource.all.limit(per_page).offset(offset).resources.send("to_#{format}")
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

      let(:dataset) { FactoryGirl.create(:my_dataset) }

      let(:type) do
        t = PublishMyData::RdfType.new('http://i-am-a-type', 'http://types')
        t.label = 'I am a type'
        t.save!
        t
      end

      before do

        # make some resources (in and out of our dataset and type)
        (1..5).each do |i|
          r = Resource.new("http://resource-in-ds/#{i}", dataset.data_graph_uri)
          r.label = "resource #{i}"
          r.write_predicate(RDF.type, RDF::URI.new(type.uri)) if i.even?
          r.save!
        end

        (1..3).each do |i|
          r = Resource.new("http://resource-not-in-ds/#{i}", 'http://anothergraph')
          r.label = "resource #{i}"
          r.write_predicate(RDF.type, RDF::URI.new(type.uri)) if i.even?
          r.save!
        end
      end

      it 'should set the resources variable' do
        get :index, use_route: :publish_my_data
        assigns['resources'].should_not be_blank
      end

      context "with no parameters" do
        it "should respond successfully" do
          get :index, use_route: :publish_my_data
        end

        it "should return paginated results for Resource.all" do
          subject.should_receive(:paginate_resources).with(Resource.all).and_call_original
          get :index, use_route: :publish_my_data
          assigns['resources'].length.should == 10 # 8 resources, plus ds and type!
        end
      end

      context 'with pagination params' do
        let(:page) {2}
        let(:per_page) {2}
        let(:offset) { (page-1)*per_page }

        it "should retreive the right page of results" do
          crit = Resource.all
          Resource.should_receive(:all).at_least(:once).and_return(crit)
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

      context 'with a type parameter' do
        context 'where the type exists' do
          before do
            get :index, type_uri: type.uri, use_route: :publish_my_data
          end

          it 'should filter the results by things of that type' do
             assigns['resources'].length.should == 3
          end

          it 'should set the type filter variable' do
            assigns['type_filter'].should == type.uri
          end

          it 'should set the dataset variable to the dataset' do
            assigns['type'].should == type
          end
        end

        context 'where the type does not exist' do
          before do
            get :index, type_uri: 'bleh', use_route: :publish_my_data
          end

          it 'should not find any results' do
            assigns['resources'].length.should == 0
          end

          it 'should set the type filter variable' do
            assigns['type_filter'].should == 'bleh'
          end

          it 'should not set the type variable' do
            assigns['type'].should be_nil
          end
        end
      end

      context "with a dataset parameter" do
        context 'where the dataset exists' do

          before do
            get :index, dataset: dataset.slug, use_route: :publish_my_data
          end

          it "should filter the results by datasets with that slug" do
            assigns['resources'].length.should == 5
          end

          it 'should set the dataset filter variable' do
            assigns['dataset_filter'].should == dataset.slug
          end

          it 'should set the dataset variable to the dataset' do
            assigns['dataset'].should == dataset
          end

        end

        context 'where the dataset does not exist' do
          before do
            get :index, dataset: 'bleh', use_route: :publish_my_data
          end

          it 'should not find any results' do
            assigns['resources'].length.should == 0
          end

          it 'should set the dataset filter variable' do
            assigns['dataset_filter'].should == 'bleh'
          end

          it 'should not set the dataset variable to the dataset' do
            assigns['dataset'].should be_nil
          end
        end
      end
    end



  end
end
