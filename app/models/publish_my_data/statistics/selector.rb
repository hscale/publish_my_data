require 'uuidtools'
require 'set'
# require 'yaml'

module PublishMyData
  module Statistics
    class Selector
      extend ActiveModel::Naming

      class InvalidIdError < ArgumentError; end

      class FilesystemRepository
        def initialize(options)
          @path = options.fetch(:path) {
            raise "Selector::FilesystemRepository must be configured with :path"
          }
        end

        def find(id)
          data = unmarshal_selector(data_for(id))
          Selector.from_hash(data)
        rescue Errno::ENOENT
          nil
        end

        def store(selector)
          FileUtils.mkdir_p(@path)
          File.open(filename_for_id(selector.id), "w") do |file|
            file << YAML.dump(marshal_selector(selector))
          end
        end

        def delete(selector)
          if persisted?(selector)
            FileUtils.rm(filename_for_id(selector.id))
          end
        end

        def persisted?(selector)
          File.file?(filename_for_id(selector.id))
        end

        def data_for(id)
          YAML.load_file(filename_for_id(id))
        end

        private

        def filename_for_id(id)
          "#{@path}/#{ensure_uuid(id)}.yml"
        end

        def ensure_uuid(maybe_uuid)
          if maybe_uuid.is_a?(UUIDTools::UUID)
            maybe_uuid
          else
            begin
              UUIDTools::UUID.parse(maybe_uuid)
            rescue ArgumentError
              raise InvalidIdError.new("Invalid Selector id: #{maybe_uuid.inspect} (not a UUID)")
            end
          end
        end

        def marshal_selector(selector)
          selector.to_h.tap do |data|
            data[:version]  = 1
            data[:id]       = data[:id].to_s
          end
        end

        def unmarshal_selector(data)
          data[:id] = UUIDTools::UUID.parse(data[:id])
          data
        end
      end

      class Labeller
        def label_for(uri)
          if resource = Resource.find(uri)
            resource.label || uri
          else
            uri
          end
        end
      end

      class HeaderColumn
        attr_reader :label
        attr_reader :number_of_encompassed_dimension_values

        def initialize(attributes = {})
          @label = attributes.fetch(:label, nil)
          @number_of_encompassed_dimension_values = attributes.fetch(:number_of_encompassed_dimension_values, 1)
        end
      end

      # Persistence API
      class << self
        def create(attributes)
          selector = new(attributes)
          selector.save
          selector
        end

        def find(id)
          repository.find(id)
        end

        def repository
          @repository ||= new_repository
        end

        def from_hash(data)
          new(
            id:             data.fetch(:id),
            geography_type: data.fetch(:geography_type),
            row_uris:       data.fetch(:row_uris)
          ).tap do |reloaded_selector|
            data.fetch(:fragments).each do |fragment_data|
              reloaded_selector.build_fragment(fragment_data)
            end
          end
        end

        private

        def new_repository
          config = PublishMyData.stats_selector

          repository_class =
            case config.fetch(:persistence_type)
            when :filesystem
              FilesystemRepository
            else
              raise "Unknown Selector persistence_type: #{persistence_type_name}"
            end

          repository_class.new(config.fetch(:persistence_options))
        end
      end

      attr_accessor :geography_type
      attr_reader   :fragments

      def initialize(attributes = {})
        @id             = attributes.fetch(:id) { UUIDTools::UUID.random_create }
        @geography_type = attributes.fetch(:geography_type)
        @row_uris       = attributes.fetch(:row_uris) { [] }

        @fragments = [ ]
      end

      def id
        @id
      end

      def to_key
        [ @id ] if persisted?
      end

      def to_param
        @id.to_s if persisted?
      end

      def valid?
        true
      end

      # To satisfy ActiveModel - we don't have any errors yet
      class Errors
        def [](key)
          [ ]
        end

        def full_messages
          [ ]
        end
      end

      def errors
        Errors.new
      end

      # ActiveModel makes us do this
      def to_partial_path
        "Because it's obviously the domain model's responsibility to determine where the view templates live"
      end

      def to_h
        {
          id:             @id,
          fragments:      @fragments.map { |fragment| fragment.to_h },
          geography_type: @geography_type,
          row_uris:       @row_uris
        }
      end

      def to_observation_query_options
        {
          row_dimension: 'http://opendatacommunities.org/def/ontology/geography/refArea',
          row_uris:      @row_uris,
          datasets:      @fragments.map(&:to_observation_query_options)
        }
      end

      def save
        Selector.repository.store(self)
      end

      def destroy
        Selector.repository.delete(self)
      end

      def persisted?
        Selector.repository.persisted?(self)
      end

      def header_rows(labeller = Labeller.new)
        # This won't handle mismatched sizes yet
        # Also hack the null case for now
        number_of_rows = @fragments.map(&:number_of_dimensions).max || 0

        bottom_up_header_rows = [ ]

        number_of_rows.times do |row_index|
          current_row = bottom_up_header_rows[row_index] = [ ]

          @fragments.each do |fragment|
            if fragment.number_of_dimensions <= row_index
              current_row << HeaderColumn.new
            else
              index_from_end = -(row_index + 1)

              columns_for_row = fragment.dimension_value_labels[index_from_end].map { |label|
                HeaderColumn.new(
                  label: labeller.label_for(label),
                  number_of_encompassed_dimension_values: fragment.number_of_encompassed_dimension_values_at_level(index_from_end)
                )
              }

              current_row.concat(columns_for_row)
            end
          end
        end

        bottom_up_header_rows.reverse
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

      def table_rows(observation_source, labeller = Labeller.new)
        @row_uris.map { |row_uri|
          Row.new(
            observation_source:   observation_source,
            row_uri:              row_uri,
            fragments:            @fragments,
            labeller:             labeller
          )
        }
      end
    end
  end
end