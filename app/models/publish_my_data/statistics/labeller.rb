module PublishMyData
  module Statistics
    # A lazy, batching labeller for resources. It listens for
    # #resource_detected, and loads all resource labels from the
    # Tripod database when the first #label_for a resource is
    # requested.
    class Labeller
      def initialize
        @resource_uris = [ ]
      end

      def resource_detected(resource_uri)
        @resource_uris << resource_uri
      end

      def label_for(resource_uri)
        labels[resource_uri] || resource_uri
      end

      private

      def labels
        @labels ||= begin
          resources.reduce({ }) { |hash, resource|
            hash.merge!(resource.uri.to_s => resource.label)
          }
        end
      end

      def resources
        Resource.find_by_sparql <<-SPARQL
          SELECT ?uri
          WHERE {
            VALUES ?uri { #{resource_uris_for_sparql.join(" ")} }
          }
        SPARQL
      end

      def resource_uris_for_sparql
        @resource_uris.map { |uri| "<#{uri}>" }
      end
    end
  end
end