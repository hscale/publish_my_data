require 'spec_helper'

module PublishMyData
  module Statistics
    describe Snapshot do
      let(:observation_source) { double(ObservationSource) }
      let(:labeller) {
        MockLabeller.new(
          'uri:dataset/1'           => "Dataset 1",
          'uri:dataset/2'           => "Dataset 2",
          'uri:dataset/3'           => "Dataset 3",
          'uri:measure-property/1'  => "Measure property 1",
          'uri:measure-property/2'  => "Measure property 2",
          'uri:measure-property/3'  => "Measure property 3",

          'uri:dim/1/a' => "Dimension 1a",
          'uri:dim/1/b' => "Dimension 1b",
          'uri:dim/2/a' => "Dimension 2a",
          'uri:dim/2/b' => "Dimension 2b",
          'uri:dim/3/a' => "Dimension 3a",
          'uri:dim/3/b' => "Dimension 3b",
          'uri:dim/4/a' => "Dimension 4a",
          'uri:dim/4/b' => "Dimension 4b",
          'uri:dim/5/a' => "Dimension 5a",
          'uri:dim/5/b' => "Dimension 5b",
          'uri:dim/6/a' => "Dimension 6a",
          'uri:dim/6/b' => "Dimension 6b"
        )
      }

      subject(:snapshot) {
        Snapshot.new(observation_source: observation_source, labeller: labeller)
      }

      describe "#header_rows" do
        def labels_for(header_rows)
          header_rows.map { |row|
            row.map { |column| column.label }
          }
        end

        def widths_for(header_rows)
          header_rows.map { |row|
            row.map { |column| column.width }
          }
        end

        context "empty" do
          before(:each) do
            # Don't inform it of any datasets (and therefore dimensions)
          end

          specify {
            # Not actually sure what this should do yet
            expect(labels_for(snapshot.header_rows)).to be == []
          }
        end

        context "one dataset, no dimensions" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dataset_completed
          end

          # It's relatively unimportant what this does as
          # it never happens in reality
          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1"], ["Measure property 1"], []
            ]
          }
        end

        context "one dataset, one dimension with two values" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri: 'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   1,
              column_uris:    ['uri:dim/1/a', 'uri:dim/1/b']
            )
            snapshot.dataset_completed
          end

          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1"],
              ["Measure property 1"],
              ["Dimension 1a", "Dimension 1b"]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows)).to be == [
              [2],
              [2],
              [1, 1]
            ]
          }
        end

        context "one dataset, two dimensions of one and two values respectively" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri: 'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   1,
              column_uris:    ['uri:dim/2/a', 'uri:dim/2/b']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   2,
              column_uris:    ['uri:dim/1/a']
            )
            snapshot.dataset_completed
          end

          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1"],
              ["Measure property 1"],
              ["Dimension 1a"],
              ["Dimension 2a", "Dimension 2b"]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows)).to be == [
              [2],
              [2],
              [2],
              [1, 1]
            ]
          }
        end

        context "one dataset, two dimensions both of two values" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   1,
              column_uris:    ['uri:dim/2/a', 'uri:dim/2/b']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   2,
              column_uris:    ['uri:dim/1/a', 'uri:dim/1/b']
            )
            snapshot.dataset_completed
          end

          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1"],
              ["Measure property 1"],
              ["Dimension 1a", "Dimension 1b"],
              ["Dimension 2a", "Dimension 2b", "Dimension 2a", "Dimension 2b"]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows)).to be == [
              [4],
              [4],
              [2, 2],
              [1, 1, 1, 1]
            ]
          }
        end

        context "two datasets, one dimension in each, with two values in the dimensions" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   1,
              column_uris:    ['uri:dim/1/a', 'uri:dim/1/b']
            )
            snapshot.dataset_completed

            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   1,
              column_uris:    ['uri:dim/2/a', 'uri:dim/2/b']
            )
            snapshot.dataset_completed
          end

          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1", "Dataset 2"],
              ["Measure property 1", "Measure property 2"],
              ["Dimension 1a", "Dimension 1b", "Dimension 2a", "Dimension 2b"]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows)).to be == [
              [2, 2],
              [2, 2],
              [1, 1, 1, 1]
            ]
          }
        end

        context "two datasets, with one and two dimensions respectively" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   1,
              column_uris:    ['uri:dim/1/a', 'uri:dim/1/b']
            )
            snapshot.dataset_completed

            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/3',
              column_width:   1,
              column_uris:    ['uri:dim/3/a', 'uri:dim/3/b']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   2,
              column_uris:    ['uri:dim/2/a']
            )
            snapshot.dataset_completed
          end

          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1", "Dataset 2"],
              ["Measure property 1", "Measure property 2"],
              [nil, "Dimension 2a"],
              ["Dimension 1a", "Dimension 1b", "Dimension 3a", "Dimension 3b"]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows)).to be == [
              [2, 2],
              [2, 2],
              [2, 2],
              [1, 1, 1, 1]
            ]
          }
        end

        context "three datasets, forming a neat little pyramid" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   1,
              column_uris:    ['uri:dim/1/a', 'uri:dim/1/b']
            )
            snapshot.dataset_completed

            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension4',
              column_width:   1,
              column_uris:    ['uri:dim/4/a', 'uri:dim/4/b']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/3',
              column_width:   2,
              column_uris:    ['uri:dim/3/a']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   2,
              column_uris:    ['uri:dim/2/a']
            )
            snapshot.dataset_completed

            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/3',
              measure_property_uri: 'uri:measure-property/3'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/5',
              column_width:   1,
              column_uris:    ['uri:dim/5/a', 'uri:dim/5/b']
            )
            snapshot.dataset_completed
          end

          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1", "Dataset 2", "Dataset 3"],
              ["Measure property 1", "Measure property 2", "Measure property 3"],
              [nil, "Dimension 2a", nil],
              [nil, "Dimension 3a", nil],
              ["Dimension 1a", "Dimension 1b", "Dimension 4a", "Dimension 4b", "Dimension 5a", "Dimension 5b"]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows)).to be == [
              [2, 2, 2],
              [2, 2, 2],
              [2, 2, 2],
              [2, 2, 2],
              [1, 1, 1, 1, 1, 1]
            ]
          }
        end

        context "three datasets, forming an asymmetric U shape" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   1,
              column_uris:    ['uri:dim/2/a']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   1,
              column_uris:    ['uri:dim/1/a']
            )
            snapshot.dataset_completed

            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/3',
              column_width:   1,
              column_uris:    ['uri:dim/3/a', 'uri:dim/3/b']
            )
            snapshot.dataset_completed

            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/3',
              measure_property_uri: 'uri:measure-property/3'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/6',
              column_width:   1,
              column_uris:    ['uri:dim/6/a']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/5',
              column_width:   1,
              column_uris:    ['uri:dim/5/a']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/4',
              column_width:   1,
              column_uris:    ['uri:dim/4/a']
            )
            snapshot.dataset_completed
          end

          specify {
            expect(labels_for(snapshot.header_rows)).to be == [
              ["Dataset 1", "Dataset 2", "Dataset 3"],
              ["Measure property 1", "Measure property 2", "Measure property 3"],
              [nil, nil, "Dimension 4a"],
              ["Dimension 1a", nil, "Dimension 5a"],
              ["Dimension 2a", "Dimension 3a", "Dimension 3b", "Dimension 6a"]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows)).to be == [
              [ 1, 2, 1 ],
              [ 1, 2, 1 ],
              [ 1, 2, 1 ],
              [ 1, 2, 1 ],
              [ 1, 1, 1, 1 ]
            ]
          }
        end
      end

      describe "#table_rows" do
        context "two datasets" do
          before(:each) do
            # The first dataset has 2 dimension values x 2 dimension values
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   1,
              column_uris:    ['uri:dim/2/a', 'uri:dim/2/b']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   2,
              column_uris:    ['uri:dim/1/a', 'uri:dim/1/b']
            )
            snapshot.dataset_completed

            # The second dataset is just to prove we can use multiple datasets
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/3',
              column_width:   1,
              column_uris:    ['uri:dim/3/a']
            )
            snapshot.dataset_completed

            # Also we need some rows
            snapshot.row_uris_detected(['uri:row/1', 'uri:row/2'])
            snapshot.row_uris_detected(['uri:row/3'])
          end

          def row_converted_to_hash(index)
            snapshot.table_rows[index].to_h
          end

          it "prepares the first row correctly (cell_coordinate ordering is really important)" do
            expect(
              row_converted_to_hash(0)
            ).to be == {
              row_uri: 'uri:row/1',
              cells: [
                {
                  dataset_uri:          'uri:dataset/1',
                  measure_property_uri: 'uri:measure-property/1',
                  row_uri:              'uri:row/1',
                  cell_coordinates:     {
                    'uri:dimension/1' => 'uri:dim/1/a',
                    'uri:dimension/2' => 'uri:dim/2/a'
                  }
                },
                {
                  dataset_uri:          'uri:dataset/1',
                  measure_property_uri: 'uri:measure-property/1',
                  row_uri:              'uri:row/1',
                  cell_coordinates:     {
                    'uri:dimension/1' => 'uri:dim/1/a',
                    'uri:dimension/2' => 'uri:dim/2/b'
                  }
                },
                {
                  dataset_uri:          'uri:dataset/1',
                  measure_property_uri: 'uri:measure-property/1',
                  row_uri:              'uri:row/1',
                  cell_coordinates:     {
                    'uri:dimension/1' => 'uri:dim/1/b',
                    'uri:dimension/2' => 'uri:dim/2/a'
                  }
                },
                {
                  dataset_uri:          'uri:dataset/1',
                  measure_property_uri: 'uri:measure-property/1',
                  row_uri:              'uri:row/1',
                  cell_coordinates:     {
                    'uri:dimension/1' => 'uri:dim/1/b',
                    'uri:dimension/2' => 'uri:dim/2/b'
                  }
                },
                {
                  dataset_uri:          'uri:dataset/2',
                  measure_property_uri: 'uri:measure-property/2',
                  row_uri:              'uri:row/1',
                  cell_coordinates:     {
                    'uri:dimension/3' => 'uri:dim/3/a'
                  }
                }
              ]
            }
          end

          it "converts the other rows too" do
            # Just random examples
            expect(row_converted_to_hash(1)[:row_uri]).to be == 'uri:row/2'
            expect(row_converted_to_hash(1)[:cells].first).to be == {
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1',
              row_uri:              'uri:row/2',
              cell_coordinates:     {
                'uri:dimension/1' => 'uri:dim/1/a',
                'uri:dimension/2' => 'uri:dim/2/a'
              }
            }
            expect(row_converted_to_hash(2)[:row_uri]).to be == 'uri:row/3'
          end
        end
      end
    end
  end
end
