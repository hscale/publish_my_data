require 'spec_helper'

module PublishMyData
  module Statistics
    describe GeographyService do
      describe "#uris_and_geography_type_for_gss_codes" do
        subject(:service) { GeographyService.new }

        before(:each) do
          GeographyTasks.create_some_gss_resources
        end

        context "a mix of GSS codes and non-GSS codes" do
          let(:gss_codes) {
            %w[ E07000036 Beans E07000008 Eggs ]
          }

          let(:result) { service.uris_and_geography_type_for_gss_codes(gss_codes) }

          it "returns the URIs of the resources with the given GSS codes" do
            # wrong! fix this next
            expect(result.fetch(:gss_resource_uris)).to be == %w[
              http://statistics.data.gov.uk/id/statistical-geography/E07000036
              http://statistics.data.gov.uk/id/statistical-geography/E07000008
            ]
          end

          it "returns the non-matching GSS codes" do
            expect(result.fetch(:non_gss_codes)).to be == %w[ Beans Eggs ]
          end
        end

        context "with GSS codes at both LA and LSOA level" do
          let(:gss_codes) {
            %w[ E07000036 E01018171 ]
          }

          it "raises a TooManyGSSCodeTypesError" do
            expect {
              service.uris_and_geography_type_for_gss_codes(gss_codes)
            }.to raise_error(GeographyService::TooManyGSSCodeTypesError)
          end
        end
      end
    end
  end
end