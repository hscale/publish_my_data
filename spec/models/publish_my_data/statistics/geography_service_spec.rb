require 'spec_helper'

module PublishMyData
  module Statistics
    describe GeographyService do
      describe "#uris_and_geography_type_for_gss_codes" do
        subject(:service) { GeographyService.new }

        before(:each) do
          Tripod::SparqlClient::Update.update(<<-TTL
            PREFIX sg: <http://statistics.data.gov.uk/id/statistical-geography/>
            PREFIX odclsoa: <http://opendatacommunities.org/id/geography/lsoa/>
            PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
            PREFIX admingeo: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>

            INSERT DATA {
              GRAPH <http://pmdtest.dev/graph/geodata> {
                # LA E07000008
                sg:E07000008 skos:notation "E07000008" .
                sg:E07000008 a <http://statistics.data.gov.uk/def/statistical-geography> .
                sg:E07000008 admingeo:gssCode "E07000008" .
                # LA E07000036
                sg:E07000036 skos:notation "E07000036" .
                sg:E07000036 a <http://statistics.data.gov.uk/def/statistical-geography> .
                sg:E07000036 admingeo:gssCode "E07000036" .
                # LSOA E01018171
                odclsoa:E01018171 skos:notation "E01018171" .
                odclsoa:E01018171 a <http://opendatacommunities.org/def/geography#LSOA> .
                odclsoa:E01018171 admingeo:gssCode "E01018171" .
              }
            }
          TTL
          )
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