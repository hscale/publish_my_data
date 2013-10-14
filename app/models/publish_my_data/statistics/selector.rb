require 'uuidtools'
require 'set'

module PublishMyData
  module Statistics
    class Selector
      include Statistics::Persistence::ActiveModelInterface

      attr_accessor :geography_type
      attr_reader   :fragments

      def initialize(attributes = {})
        @id             = attributes.fetch(:id) { UUIDTools::UUID.random_create }
        @geography_type = attributes.fetch(:geography_type)
        @row_uris       = attributes.fetch(:row_uris) { [] }

        @fragments = [ ]
      end

      def to_h
        {
          id:             @id,
          fragments:      @fragments.map { |fragment| fragment.to_h },
          geography_type: @geography_type,
          row_uris:       @row_uris
        }
      end

      def take_snapshot(snapshot, observation_source, labeller, options = {})
        row_uris = rows_uris_for_snapshot(options)

        observation_source.row_uris_detected(
          # The current version of the Stats Selector hard-codes this
          'http://opendatacommunities.org/def/ontology/geography/refArea',
          row_uris
        )
        row_uris.each do |row_uri|
          labeller.resource_detected(row_uri)
        end

        @fragments.each do |fragment|
          fragment.inform_observation_source(observation_source)
          fragment.inform_snapshot(snapshot)
          fragment.inform_labeller(labeller)
        end

        # We could actually treat this as a command method and
        # return nil if we wanted, the snapshot was given to us
        snapshot
      end

      def build_fragment(fragment_description)
        fragment = Fragment.new(fragment_description)
        @fragments << fragment
        fragment
      end

      def remove_fragment(fragment_id)
        @fragments.reject! { |fragment| fragment.id == fragment_id }
      end

      class Row
        def initialize(attributes)
          @observation_source   = attributes.fetch(:observation_source)
          @row_uri              = attributes.fetch(:row_uri)
          @fragments            = attributes.fetch(:fragments)
          @labeller             = attributes.fetch(:labeller)
        end

        def label
          @labeller.label_for(@row_uri)
        end

        def values
          @fragments.inject([]) { |values, fragment|
            values.concat(
              fragment.values_for_row(
                row_uri:              @row_uri,
                observation_source:   @observation_source
              )
            )
          }
        end
      end

      def table_rows(observation_source, labeller)
        @row_uris.map { |row_uri|
          Row.new(
            observation_source:   observation_source,
            row_uri:              row_uri,
            fragments:            @fragments,
            labeller:             labeller
          )
        }
      end

      private

      def rows_uris_for_snapshot(options)
        row_limit = options.fetch(:row_limit, 0) - 1
        @row_uris[0..row_limit]
      end
    end
  end
end