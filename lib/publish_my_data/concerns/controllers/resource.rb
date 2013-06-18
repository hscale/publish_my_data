module PublishMyData
  module Concerns
    module Controllers
      module Resource
        extend ActiveSupport::Concern

        included do

          private

          def render_resource_with_uri(uri)
            resource = PublishMyData::Resource.find(uri)

            respond_with(resource) do |format|
              format.html { render resource.render_params(request) }
            end
          end

        end
      end
    end
  end
end