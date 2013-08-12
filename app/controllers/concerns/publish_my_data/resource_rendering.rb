module PublishMyData
  module ResourceRendering
    extend ActiveSupport::Concern

    included do

      private

      def render_resource(resource)
        respond_with(resource) do |format|
          format.html do
            resource.eager_load!

            logger.debug(locals_for_resource(resource))
            render template: template_for_resource(resource), locals: locals_for_resource(resource)
          end
        end
      end

      def template_for_resource(resource)
        {
          Dataset       => 'publish_my_data/datasets/show',
          Ontology      => 'publish_my_data/ontologies/show',
          ConceptScheme => 'publish_my_data/concept_schemes/show',
          OntologyClass => 'publish_my_data/classes/show',
          Property      => 'publish_my_data/properties/show',
          Concept       => 'publish_my_data/concepts/show',
          Resource      => 'publish_my_data/resources/show',
          ThirdParty::Ontology =>       'publish_my_data/ontologies/show',
          ThirdParty::ConceptScheme =>  'publish_my_data/concept_schemes/show'
        }[resource.class]
      end

      def locals_for_resource(resource)
        key = resource.class.name.demodulize.underscore.to_sym
        {key => resource}
      end
    end
  end
end