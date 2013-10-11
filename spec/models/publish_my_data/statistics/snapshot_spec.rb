require 'spec_helper'

module PublishMyData
  module Statistics
    describe Snapshot do
      subject(:snapshot) { Snapshot.new }

      describe "#header_rows" do
        # Where's also a mock labeller in the Selector spec too
        # (we need to merge these)
        class MockLabeller
          TEST_LABELS = {
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
            'uri:dim/6/a' => "Dimension 6a"
          }.freeze

          def label_for(uri)
            TEST_LABELS.fetch(uri, "<label not found>")
          end
        end

        let(:labeller) { MockLabeller.new }

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
            expect(labels_for(snapshot.header_rows(labeller))).to be == []
          }
        end

        context "one dataset, no dimensions" do
          before(:each) do
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/1',
              measure_property_uri: 'uri:measure-property/1'
            )
          end

          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [[]]
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
          end

          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [
              [ "Dimension 1a", "Dimension 1b" ]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows(labeller))).to be == [
              [ 1, 1 ]
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
          end

          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [
              [ "Dimension 1a" ],
              [ "Dimension 2a", "Dimension 2b" ]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows(labeller))).to be == [
              [ 2 ], [ 1, 1 ]
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
              column_uris:    ['uri:dim/2/a', 'uri:dim/2/b', 'uri:dim/2/a', 'uri:dim/2/b']
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/1',
              column_width:   2,
              column_uris:    ['uri:dim/1/a', 'uri:dim/1/b']
            )
          end

          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [
              [ "Dimension 1a", "Dimension 1b" ],
              [ "Dimension 2a", "Dimension 2b", "Dimension 2a", "Dimension 2b" ]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows(labeller))).to be == [
              [ 2, 2 ], [ 1, 1, 1, 1 ]
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
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/2',
              column_width:   1,
              column_uris:    ['uri:dim/2/a', 'uri:dim/2/b']
            )
          end

          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [
              [ "Dimension 1a", "Dimension 1b", "Dimension 2a", "Dimension 2b" ]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows(labeller))).to be == [
              [ 1, 1, 1, 1 ]
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
          end

          # It would be nice to have one blank column of width 2,
          # but that would be harder to implement (we'd need to remember
          # the widths of the datasets)
          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [
              [ nil, nil, "Dimension 2a" ],
              [ "Dimension 1a", "Dimension 1b", "Dimension 3a", "Dimension 3b" ]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows(labeller))).to be == [
              [ 1, 1, 2 ],
              [ 1, 1, 1, 1 ]
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
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/4',
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
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/3',
              measure_property_uri: 'uri:measure-property/3'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/5',
              column_width:   1,
              column_uris:    ['uri:dim/5/a', 'uri:dim/5/b']
            )
          end

          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [
              [ nil, nil, "Dimension 2a", nil, nil ],
              [ nil, nil, "Dimension 3a", nil, nil ],
              [ "Dimension 1a", "Dimension 1b", "Dimension 4a", "Dimension 4b", "Dimension 5a", "Dimension 5b" ]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows(labeller))).to be == [
              [ 1, 1, 2, 1, 1 ],
              [ 1, 1, 2, 1, 1 ],
              [ 1, 1, 1, 1, 1, 1 ]
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
            snapshot.dataset_detected(
              dataset_uri:          'uri:dataset/2',
              measure_property_uri: 'uri:measure-property/2'
            )
            snapshot.dimension_detected(
              dimension_uri:  'uri:dimension/3',
              column_width:   1,
              column_uris:    ['uri:dim/3/a', 'uri:dim/3/b']
            )
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
          end

          specify {
            expect(labels_for(snapshot.header_rows(labeller))).to be == [
              [ nil, nil, nil, "Dimension 4a" ],
              [ "Dimension 1a", nil, nil, "Dimension 5a" ],
              [ "Dimension 2a", "Dimension 3a", "Dimension 3b", "Dimension 6a" ]
            ]
          }

          specify {
            expect(widths_for(snapshot.header_rows(labeller))).to be == [
              [ 1, 1, 1, 1 ],
              [ 1, 1, 1, 1 ],
              [ 1, 1, 1, 1 ]
            ]
          }
        end
      end
    end
  end
end
