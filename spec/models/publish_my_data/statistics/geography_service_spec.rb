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
            expect(result.fetch(:gss_resource_uris)).to match_array(
              %w[
                http://statistics.data.gov.uk/id/statistical-geography/E07000036
                http://statistics.data.gov.uk/id/statistical-geography/E07000008
              ]
            )
          end

          it "returns the non-matching GSS codes" do
            expect(result.fetch(:non_gss_codes)).to match_array(%w[ Beans Eggs ])
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

    describe ".geographical_data_cubes" do
      let!(:data_cube) { FactoryGirl.create(:data_cube) }
      let!(:geo_data_cube) { FactoryGirl.create(:geo_data_cube) }

      before do
        GeographyTasks.create_some_gss_resources
        GeographyTasks.populate_dataset_with_geographical_observations(geo_data_cube)
      end

      it "should return data cubes where there is an observation with a reference area relating to the given RDF type" do
        GeographyService.geographical_data_cubes("http://opendatacommunities.org/def/local-government/LocalAuthority").map(&:uri).should include(geo_data_cube.uri)
      end

      it "should not return data cubes where the observations do not contain a relevant geographical component" do
        GeographyService.geographical_data_cubes("http://opendatacommunities.org/def/local-government/LocalAuthority").map(&:uri).should_not include(data_cube.uri)
      end
    end
  end
end