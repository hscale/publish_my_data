require 'spec_helper'

module PublishMyData
  describe Dataset do
    it_behaves_like PublishMyData::AllFeatures do
      let(:resource) { FactoryGirl.build(:my_dataset) }
    end

    describe ".uri_from_slug" do
      it "returns a uri given a slug" do
        slug = "sluggy/my-slug"
        Dataset.uri_from_slug(slug).should == "http://pmdtest.dev/data/#{slug}"
      end
    end

    describe ".slug_from_uri" do
      it "returns a slug given a uri" do
        slug = "sluggy/my-slug"
        Dataset.slug_from_uri("http://pmdtest.dev/data/#{slug}").should == slug
      end
    end

    describe ".find_by_slug" do
      it "should perform a find on the uri for the slug" do
        slug = "sluggy/my-slug"
        Dataset.should_receive(:find).with(Dataset.uri_from_slug(slug))
        Dataset.find_by_slug(slug)
      end
    end
  end
end