require 'spec_helper'

module PublishMyData
  module Statistics
    Snapshot.class_eval do
      describe Snapshot::TableRow do
        let(:observation_source) {
          # Currently almost the same as the data in the Fragment spec
          # This could probably be replaced with an RSpec double now
          MockObservationSource.new(
            measure_property_uris: %w[ uri:measure-property/1 uri:measure-property/2 ],
            observation_data: {
              'uri:dataset/1' => {
                'uri:row/1' => {
                  'uri:dimension/1' => {
                    'uri:dim/1/a' => {
                      'uri:dimension/2' => {
                        'uri:dim/2/a' => 1,
                        'uri:dim/2/b' => 2
                      }
                    },
                    'uri:dim/1/b' => {
                      'uri:dimension/2' => {
                        'uri:dim/2/a' => 3,
                        'uri:dim/2/b' => 4
                      }
                    }
                  }
                }
              },
              'uri:dataset/2' => {
                'uri:row/1' => {
                  'uri:dimension/3' => {
                    'uri:dim/3/a' => 5
                  }
                }
              }
            }
          )
        }

        let(:labeller) { double(Labeller) }

        # This is an internal structure built up by a Snapshot for the
        # purpose of constructing a TableRow
        let(:dataset_descriptions) {
          [
            {
              dataset_uri: 'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              cell_coordinates: [
                {
                  'uri:dimension/1' => 'uri:dim/1/a',
                  'uri:dimension/2' => 'uri:dim/2/a'
                },
                {
                  'uri:dimension/1' => 'uri:dim/1/a',
                  'uri:dimension/2' => 'uri:dim/2/b'
                },
                {
                  'uri:dimension/1' => 'uri:dim/1/b',
                  'uri:dimension/2' => 'uri:dim/2/a'
                },
                {
                  'uri:dimension/1' => 'uri:dim/1/b',
                  'uri:dimension/2' => 'uri:dim/2/b'
                }
              ]
            },
            {
              dataset_uri: 'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2',
              cell_coordinates: [
                {
                  'uri:dimension/3' => 'uri:dim/3/a'
                }
              ]
            }
          ]
        }

        subject(:row) {
          Snapshot::TableRow.new(
            row_uri: 'uri:row/1',
            dataset_descriptions: dataset_descriptions,
            observation_source: observation_source,
            labeller: labeller
          )
        }

        describe "#cells" do
          specify {
            expect(row.map(&:value)).to be == [1, 2, 3, 4, 5]
          }
        end

        describe "#values" do
          specify {
            expect(row.values).to be == [1, 2, 3, 4, 5]
          }
        end
      end
    end
  end
end