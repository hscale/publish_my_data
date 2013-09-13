require 'csv'

module PublishMyData
  module CubeResults
    extend ActiveSupport::Concern

    def loop_and_page_sparql_query(sparql, page_size=5000)
      results = []
      try_again = true
      page = 1
      while try_again
        page_start = Time.now
        # we need to paginate
        sparql_query = PublishMyData::SparqlQuery.new(sparql, {:request_format => :json} )
        sparql_query_result = JSON.parse(sparql_query.paginate(page, page_size).to_s)["results"]["bindings"]
        try_again = (sparql_query_result.length == page_size) # this page is full - keep going!
        page += 1
        results += sparql_query_result
        Rails.logger.debug(">>>> getting page of sparql took #{Time.now - page_start}s")
      end
      results
    end

    # pass sparql results and convert to a minimal hash
    # ready for conversion to json.
    def uris_and_labels_only(sparql_results)

      start_uris_and_labels = Time.now

      uris_and_labels_array = []
      uris_hash = {}

      # use a hash so we only get one result per label
      sparql_results.each do |result|
        uri = result["uri"]["value"]
        label = result["label"]["value"] if result["label"]
        uris_hash[uri] ||= label # only store the label if we've not got one
      end

      # now go through and make it into a hash
      uris_hash.each_pair do |uri, label|
        uris_and_labels_array << {uri: uri, label: label }
      end

      uris_and_labels_array
    end


  end
end

