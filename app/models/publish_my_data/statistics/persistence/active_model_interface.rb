module PublishMyData
  module Statistics
    module Persistence
      # ActiveModel and related persistence class methods (hides a
      # Repository pattern behind an ActiveModel interface)
      module ActiveModelInterface
        module ClassMethods
          include ActiveModel::Naming

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
                Statistics::Persistence::FilesystemSelectorRepository
              else
                raise "Unknown Selector persistence_type: #{persistence_type_name}"
              end

            repository_class.new(config.fetch(:persistence_options))
          end
        end

        module InstanceMethods
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

          def save
            Selector.repository.store(self)
          end

          def destroy
            Selector.repository.delete(self)
          end

          def persisted?
            Selector.repository.persisted?(self)
          end
        end

        def self.included(receiver)
          receiver.extend         ClassMethods
          receiver.send :include, InstanceMethods
        end
      end
    end
  end
end