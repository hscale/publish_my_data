require 'uuidtools'
# require 'yaml'

module PublishMyData
  module Statistics
    class Selector
      class FilesystemRepository
        def initialize(options)
          @path = options.fetch(:path) {
            raise "Selector::FilesystemRepository must be configured with :path"
          }
        end

        def find(id)
          data = unmarshal_selector(YAML.load_file(filename_for_id(id)))
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

        private

        def filename_for_id(id)
          "#{@path}/#{id}.yml"
        end

        def marshal_selector(selector)
          selector.to_h.tap do |data|
            data[:id] = data[:id].to_s
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

        def initialize(attributes = { })
          @label = attributes.fetch(:label, nil)
          @number_of_encompassed_dimension_values = attributes.fetch(:number_of_encompassed_dimension_values, 1)
        end
      end

      # Configuration API
      class << self
        def configure(&block)
          yield self
          instantiate_repository
        end

        def persistence_type=(persistence_type_name)
          @repository_class =
            case persistence_type_name
            when :filesystem
              FilesystemRepository
            else
              raise "Unknown Selector persistence_type: #{persistence_type_name}"
            end
        end

        def persistence_options=(persistence_options)
          @persistence_options = persistence_options
        end

        # This method assumes the repository is stateless. If not, and you're
        # running in a multi-threaded environment, you're on your own.
        def instantiate_repository
          @repository = @repository_class.new(@persistence_options)
        end
      end

      # Persistence API
      class << self
        def create
          selector = new
          selector.save
          selector
        end

        def find(id)
          @repository.find(id)
        end

        def repository
          @repository
        end

        def from_hash(data)
          new(id: data.fetch(:id)).tap do |reloaded_selector|
            data.fetch(:fragments).each do |fragment_data|
              reloaded_selector.build_fragment(fragment_data)
            end
          end
        end
      end

      attr_reader :fragments

      def initialize(attributes = { })
        @id = attributes.fetch(:id) { UUIDTools::UUID.random_create }
        @fragments = [ ]
      end

      def id
        @id
      end

      def to_param
        raise "Use the id now"
      end

      def to_h
        {
          id: @id,
          fragments: @fragments.map { |fragment| fragment.to_h }
        }
      end

      def save
        Selector.repository.store(self)
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
        @fragments << Fragment.new(fragment_description)
      end

      def rows
        Resource.find_by_sparql("
          SELECT distinct ?uri
          WHERE {
            ?uri a <http://statistics.data.gov.uk/def/statistical-geography>.
          }
          LIMIT 20
        ")
      end
    end
  end
end