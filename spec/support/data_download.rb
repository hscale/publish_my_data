shared_examples 'a controller with a dump action' do
  describe "#dump" do

    before do
      s3 = AWS::S3.new
      bucket = s3.buckets[PublishMyData.downloads_s3_bucket]
      bucket.clear! # wipe the bucket
    end

    context "where the given slug exists" do
      context "when a download exists on s3" do
        before do
          # make some downloads.
          s3 = AWS::S3.new
          bucket = s3.buckets[PublishMyData.downloads_s3_bucket]
          @object = bucket.objects.create(resource.download_prefix, 'data')
          @object.acl = :public_read
        end

        it "should redirect to the latest download that exists for the resource" do
          get :dump, :id => resource.slug, :use_route => :publish_my_data
          response.should be_redirect
          response.should redirect_to(@object.public_url.to_s)
        end
      end

      context "when a download exists on s3 for a previous day" do
        before do
          # make some downloads.
          s3 = AWS::S3.new
          bucket = s3.buckets[PublishMyData.downloads_s3_bucket]

          resource.modified = resource.modified - 1.day # temp. set the modified date so a new backup prefix is generated
          @object = bucket.objects.create(resource.download_prefix, 'data')
          resource.modified = resource.modified + 1.day # and now set it back again!
          @object.acl = :public_read
        end

        it "should 404" do
          get :dump, :id => resource.slug, :use_route => :publish_my_data
          response.should be_not_found
        end
      end

      context "when a download doesn't exist on s3" do
        it "should 404" do
          get :dump, :id => resource.slug, :use_route => :publish_my_data
          response.should be_not_found
        end
      end
    end

    context "when a resource with that slug doesn't exist" do
      it "should 404" do
        get :dump, :id => "i-dont-exist", :use_route => :publish_my_data
        response.should be_not_found
      end
    end
  end
end