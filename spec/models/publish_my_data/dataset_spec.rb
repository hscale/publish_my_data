require 'spec_helper'

module PublishMyData
  describe Dataset do

    describe ".uri_from_slug" do
      it "returns the a uri given the slug" do
        slug = "my-slug"
        Dataset.uri_from_slug(slug).should == "http://pmdtest.dev/data/#{slug}"
      end
    end

    describe ".slug_from_uri" do
      it "returns a slug given a uri" do
        slug = "my-slug"
        Dataset.slug_from_uri("http://pmdtest.dev/datasets/#{slug}").should == slug
      end
    end

    describe ".find_by_slug" do
      it "should perform a find on the uri for the slug" do
        slug = "my-slug"
        Dataset.should_receive(:find).with(Dataset.uri_from_slug(slug))
        Dataset.find_by_slug(slug)
      end
    end
  end
end

