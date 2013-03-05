require 'spec_helper'

module PublishMyData
  describe ThemesController do

    before do
      (1..5).each do |i|
        slug = i
        uri = "http://#{PublishMyData.local_domain}/def/theme/#{i}"
        t = PublishMyData::Theme.new(uri)
        t.label = "Theme #{i}"
        t.description = "A theme"
        t.save!
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
          assigns['themes'].length.should ==5
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