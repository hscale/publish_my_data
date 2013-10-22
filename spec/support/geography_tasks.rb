module GeographyTasks
  def self.create_some_gss_resources
    Tripod::SparqlClient::Update.update(<<-TTL
      PREFIX rdfs: <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX sg: <http://statistics.data.gov.uk/id/statistical-geography/>
      PREFIX la: <http://opendatacommunities.org/id/district-council/>
      PREFIX lg: <http://opendatacommunities.org/def/local-government/>
      PREFIX odclsoa: <http://opendatacommunities.org/id/geography/lsoa/>
      PREFIX skos: <http://www.w3.org/2004/02/skos/core#>
      PREFIX admingeo: <http://data.ordnancesurvey.co.uk/ontology/admingeo/>

      INSERT DATA {
        GRAPH <http://pmdtest.dev/graph/geodata> {
          # LA E07000008
          sg:E07000008 admingeo:gssCode "E07000008" .
          sg:E07000008 rdfs:label "E07000008 Cambridge" .
          la:cambridge a lg:LocalAuthority .
          la:cambridge lg:governsGSS sg:E07000008 .
          # LA E07000036
          sg:E07000036 admingeo:gssCode "E07000036" .
          sg:E07000036 rdfs:label "E07000036 Erewash" .
          la:erewash a lg:LocalAuthority .
          la:erewash lg:governsGSS sg:E07000036 .
          # LSOA E01018171
          odclsoa:E01018171 skos:notation "E01018171" .
          odclsoa:E01018171 a <http://opendatacommunities.org/def/geography#LSOA> .
        }
      }
    TTL
    )
  end

  def self.create_relevant_vocabularies
    Tripod::SparqlClient::Update.update(<<-TTL
      PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX gce:   <http://opendatacommunities.org/def/concept/general-concepts/ethnicity/>
      PREFIX theme: <http://opendatacommunities.org/def/concept/themes/>
      PREFIX rp:    <http://reference.data.gov.uk/id/quarter/>
      PREFIX og:    <http://opendatacommunities.org/def/ontology/geography/>
      PREFIX ot:    <http://opendatacommunities.org/def/ontology/time/>
      PREFIX oha:   <http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/>
      PREFIX qb:    <http://purl.org/linked-data/cube#>
      
      INSERT DATA {
        GRAPH <http://pmdtest.dev/vocabularies/all> {
          # Ethnicities
          gce:white rdfs:label "White" .
          gce:mixed rdfs:label "Mixed" .
          gce:black rdfs:label "Black" .
          gce:asian rdfs:label "Asian" .
          # Reference Periods
          rp:2013-Q1 rdfs:label "2013 Q1" .
          rp:2013-Q2 rdfs:label "2013 Q2" .
          # Dimension Properties
          og:refArea    a           qb:DimensionProperty .
          og:refArea    rdfs:label  "Reference Area" .
          ot:refPeriod  a           qb:DimensionProperty .
          ot:refPeriod rdfs:label   "Reference Period" .
          oha:ethnicity a           qb:DimensionProperty .
          oha:ethnicity rdfs:label  "Ethnicity" .
          # Measure Properties
          oha:homelessnessAcceptancesObs a qb:MeasureProperty .
        }
        # Themes
        GRAPH <#{Theme.theme_graph}> {
          theme:homelessness a <#{RDF::SITE.Theme}> .
          theme:homelessness rdfs:label "Homeslessness" .
        }
      }
    TTL
    )
  end

  def self.populate_dataset_with_geographical_observations(dataset)
    Tripod::SparqlClient::Update.update(<<-TTL
      PREFIX rdfs:  <http://www.w3.org/2000/01/rdf-schema#>
      PREFIX dcat:  <http://www.w3.org/ns/dcat#>
      PREFIX sg:    <http://statistics.data.gov.uk/id/statistical-geography/>
      PREFIX obs:   <http://example.com/observations/>
      PREFIX og:    <http://opendatacommunities.org/def/ontology/geography/>
      PREFIX ot:    <http://opendatacommunities.org/def/ontology/time/>
      PREFIX oha:   <http://opendatacommunities.org/def/ontology/homelessness/homelessness-acceptances/>
      PREFIX gce:   <http://opendatacommunities.org/def/concept/general-concepts/ethnicity/>
      PREFIX theme: <http://opendatacommunities.org/def/concept/themes/>
      PREFIX rp:    <http://reference.data.gov.uk/id/quarter/>
      PREFIX qb:    <http://purl.org/linked-data/cube#>
      
      INSERT DATA {
        GRAPH <#{ dataset.metadata_graph_uri }> {
          <#{dataset.uri}> dcat:theme theme:homelessness .
        }
        GRAPH <#{ dataset.data_graph_uri }> {
          obs:1 qb:dataSet                      <#{dataset.uri}> .
          obs:1 og:refArea                      sg:E07000008 .
          obs:1 ot:refPeriod                    rp:2013-Q1 .
          obs:1 oha:ethnicity                   gce:white .
          obs:1 oha:homelessnessAcceptancesObs  123 .

          obs:2 qb:dataSet                      <#{dataset.uri}> .
          obs:2 og:refArea                      sg:E07000008 .
          obs:2 ot:refPeriod                    rp:2013-Q1 .
          obs:2 oha:ethnicity                   gce:mixed .
          obs:2 oha:homelessnessAcceptancesObs  234 .

          obs:3 qb:dataSet                      <#{dataset.uri}> .
          obs:3 og:refArea                      sg:E07000008 .
          obs:3 ot:refPeriod                    rp:2013-Q1 .
          obs:3 oha:ethnicity                   gce:black .
          obs:3 oha:homelessnessAcceptancesObs  345 .

          obs:4 qb:dataSet                      <#{dataset.uri}> .
          obs:4 og:refArea                      sg:E07000008 .
          obs:4 ot:refPeriod                    rp:2013-Q2 .
          obs:4 oha:ethnicity                   gce:white .
          obs:4 oha:homelessnessAcceptancesObs  456 .

          obs:5 qb:dataSet                      <#{dataset.uri}> .
          obs:5 og:refArea                      sg:E07000008 .
          obs:5 ot:refPeriod                    rp:2013-Q2 .
          obs:5 oha:ethnicity                   gce:mixed .
          obs:5 oha:homelessnessAcceptancesObs  567 .

          obs:6 qb:dataSet                      <#{dataset.uri}> .
          obs:6 og:refArea                      sg:E07000008 .
          obs:6 ot:refPeriod                    rp:2013-Q2 .
          obs:6 oha:ethnicity                   gce:black .
          obs:6 oha:homelessnessAcceptancesObs  678 .

          obs:7 qb:dataSet                      <#{dataset.uri}> .
          obs:7 og:refArea                      sg:E07000036 .
          obs:7 ot:refPeriod                    rp:2013-Q1 .
          obs:7 oha:ethnicity                   gce:white .
          obs:7 oha:homelessnessAcceptancesObs  1234 .

          obs:8 qb:dataSet                      <#{dataset.uri}> .
          obs:8 og:refArea                      sg:E07000036 .
          obs:8 ot:refPeriod                    rp:2013-Q1 .
          obs:8 oha:ethnicity                   gce:mixed .
          obs:8 oha:homelessnessAcceptancesObs  2345 .

          obs:9 qb:dataSet                      <#{dataset.uri}> .
          obs:9 og:refArea                      sg:E07000036 .
          obs:9 ot:refPeriod                    rp:2013-Q1 .
          obs:9 oha:ethnicity                   gce:black .
          obs:9 oha:homelessnessAcceptancesObs  3456 .

          obs:10 qb:dataSet                      <#{dataset.uri}> .
          obs:10 og:refArea                      sg:E07000036 .
          obs:10 ot:refPeriod                    rp:2013-Q2 .
          obs:10 oha:ethnicity                   gce:white .
          obs:10 oha:homelessnessAcceptancesObs  4567 .

          obs:11 qb:dataSet                      <#{dataset.uri}> .
          obs:11 og:refArea                      sg:E07000036 .
          obs:11 ot:refPeriod                    rp:2013-Q2 .
          obs:11 oha:ethnicity                   gce:mixed .
          obs:11 oha:homelessnessAcceptancesObs  5678 .

          obs:12 qb:dataSet                      <#{dataset.uri}> .
          obs:12 og:refArea                      sg:E07000036 .
          obs:12 ot:refPeriod                    rp:2013-Q2 .
          obs:12 oha:ethnicity                   gce:black .
          obs:12 oha:homelessnessAcceptancesObs  6789 .
        }
      }
    TTL
    )
  end
end