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

      let!(:resource) { FactoryGirl.create(:yuri_unicorn_resource) }

      it "should respond successfully" do
        get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        response.should be_success
      end

      context "for html" do
        it "should eager load the labels" do
          Resource.should_receive(:find).and_return(resource)
          resource.should_receive(:eager_load_predicate_triples!)
          resource.should_receive(:eager_load_object_triples!)
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        context "with an arbitrary resource" do
          it "should render the show template" do
            get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
            response.should render_template("publish_my_data/resources/show")
          end
        end
      end

      context "with an alternative mime type passed in the header" do

        before do
          @request.env['HTTP_ACCEPT'] = "application/rdf+xml"
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        it "should resond with the right mime type" do
          response.content_type.should == Mime::RDF.to_s + "; charset=utf-8"
        end

        it "should respond with the right content" do
          response.body.should == resource.to_rdf
        end

        it "should not eager load the labels" do
          Resource.should_receive(:find).and_return(resource)
          resource.should_not_receive(:eager_load_predicate_triples!)
          resource.should_not_receive(:eager_load_object_triples!)
          get :doc, :path => "unicorns/yuri", use_route: :publish_my_data
        end

        context "and the resource doesn't exist" do
          it "should 404 with a blank response" do
            get :doc, :path => "unicorns/borat", use_route: :publish_my_data
            response.should be_not_found
            response.body.should == "Not Found"
          end
        end

      end

      context "with an alternative format passed on the url" do

        it "should resond with the right mime type" do
          get :doc, :path => "unicorns/yuri", format: 'ttl', use_route: :publish_my_data
          response.content_type.should == Mime::TTL.to_s + "; charset=utf-8"
        end

        it "should respond with the right content" do
          get :doc, :path => "unicorns/yuri", format: 'ttl', use_route: :publish_my_data
          response.body.should == resource.to_ttl
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

      let!(:resource) { FactoryGirl.create(:mean_result) }
      let!(:theme) { FactoryGirl.create(:my_theme) }
      let!(:onotology) { FactoryGirl.create(:ontology) }
      let!(:concept_scheme) { FactoryGirl.create(:concept_scheme) }

      before do
        # make some datasets
        (1..30).each do |i|
          slug = i
          uri = PublishMyData::Dataset.uri_from_slug(slug)
          graph = PublishMyData::Dataset.metadata_graph_uri(slug)
          d = PublishMyData::Dataset.new(uri, graph)
          d.theme = theme.uri if i.even?
          d.title = "Dataset #{i.to_s}"
          d.save!
        end
      end

      context "for resource in our database" do

        it "should respond successfully" do
          get :definition, :path => "statistics/meanResult", use_route: :publish_my_data
          response.should be_success
        end

        context "for an html request" do

          context "for an abitrary resource" do
            it "should render the show template" do
              get :definition, :path => "statistics/meanResult", use_route: :publish_my_data
              response.should render_template("publish_my_data/resources/show")
            end
          end

          context "when resource is an ontology" do
            it "should render the ontologies#show template" do
              get :definition, :path => "my-topic/ontology", use_route: :publish_my_data
              response.should render_template("publish_my_data/ontologies/show")
            end
          end

          context "when resource is a concept scheme" do
            it "should render the concept_schemes#show template" do
              get :definition, :path => "my-topic/concept-scheme/my-concept-scheme", use_route: :publish_my_data
              response.should render_template("publish_my_data/concept_schemes/show")
            end
          end

        end


        context "with an alternative mime type" do
          it "should with the right mime type and content" do
            get :definition, :path => "statistics/meanResult", :format => 'nt', use_route: :publish_my_data
            response.content_type.should == Mime::NT
            response.body.should == resource.to_nt
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

      context "with no uri parameter" do
        before do
          get :show, use_route: :publish_my_data
        end
        it "should respond with not found" do
          response.should be_not_found
        end
      end

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

        let!(:resource) { FactoryGirl.create(:foreign_resource) }
        let!(:external_concept_scheme) { FactoryGirl.create(:external_concept_scheme) }
        let!(:external_ontology) { FactoryGirl.create(:external_ontology) }

        it "should respond succesfully" do
          get :show, :uri => resource.uri, use_route: :publish_my_data
          response.should be_success
        end

        it "should render the show template" do
          get :show, :uri => resource.uri, use_route: :publish_my_data
          response.should render_template("publish_my_data/resources/show")
        end

        context "when resource is an ontology" do
          it "should render the ontologies#show template" do
            get :show, :uri => external_ontology.uri, use_route: :publish_my_data
            response.should render_template("publish_my_data/ontologies/show")
          end
        end

        context "when resource is a concept scheme" do
          it "should render the concept_schemes#show template" do
            get :show, :uri => external_concept_scheme.uri, use_route: :publish_my_data
            response.should render_template("publish_my_data/concept_schemes/show")
          end
        end

      end
    end

    describe "#index" do

      shared_examples_for "resource kaminari pagination" do
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

      shared_examples_for "a resource collection in non-html" do
        it "should render the collection in the right format" do
          get :index, :page => page, :per_page => per_page, :format => format, use_route: :publish_my_data
          puts format
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
        t = PublishMyData::RdfType.new('http://example.com/i-am-a-type', 'http://example.com/types')
        t.label = 'I am a type'
        t.save!
        t
      end

      before do

        # make some resources (in and out of our dataset and type)
        (1..5).each do |i|
          r = Resource.new("http://example.com/resource-in-ds/#{i}", dataset.data_graph_uri)
          r.label = "resource #{i}"
          r.write_predicate(RDF.type, RDF::URI.new(type.uri)) if i.even?
          r.save!
        end

        (1..3).each do |i|
          r = Resource.new("http://example.com/resource-not-in-ds/#{i}", 'http://example.com/anothergraph')
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
          Paginator.should_receive(:new).with(Resource.all, ResourcePaginationParams.from_request(@request)).and_call_original
          get :index, use_route: :publish_my_data
          assigns['resources'].length.should == 10 # 8 resources, plus ds and type!
        end
      end

      context 'with pagination params' do
        let(:page) {2}
        let(:per_page) {2}
        let(:offset) { (page-1)*per_page }

        it "should retreive the right page of results" do
          PublishMyData::SparqlQuery.any_instance.should_receive(:as_pagination_query).with(page, per_page)
          get :index, page: page, per_page: per_page, use_route: :publish_my_data
        end

        it_should_behave_like "resource kaminari pagination"

        context 'with non-html format' do
          let(:format) {'ttl'}
          it_should_behave_like "a resource collection in non-html"
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
