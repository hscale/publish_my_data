require 'spec_helper'

module PublishMyData
  describe SelectorsController do
    describe "#preview" do
      context "given an uploaded text file containing GSS codes" do
        let(:csv_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_etc.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: csv_upload, use_route: :publish_my_data
          response.should be_success
        end
      end

      context "given a file of invalid format" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/dog.gif'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: invalid_upload, use_route: :publish_my_data
          response.should be_success
        end

        it "should flash an error message" do
          post :preview, csv_upload: invalid_upload, use_route: :publish_my_data
          flash[:error].should_not be_nil
        end
      end

      context "given a file containing a mix of LA and LSOA GSS codes" do
        let(:invalid_upload) {
          temp_file = File.new(File.join(Rails.root, '../support/gss_mixed.csv'))
          ActionDispatch::Http::UploadedFile.new(tempfile: temp_file, filename: File.basename(temp_file.path))
        }

        it "should respond successfully" do
          post :preview, csv_upload: invalid_upload, use_route: :publish_my_data
          response.should be_success
        end

        it "should flash an error message" do
          post :preview, csv_upload: invalid_upload, use_route: :publish_my_data
          flash[:error].should_not be_nil
        end
      end
    end
  end
end