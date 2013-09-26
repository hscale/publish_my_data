# Introduction to PublishMyData data modelling

This readme is a short overview of the data used in PublishMyData.

We will assume here that the local domain for data is "pmd.dev". Some real-world examples are taken from [Open Data Communities][odc].

[odc]: http://opendatacommunities.org/

## PublishMyData Datasets

Datasets are a concept in PublishMyData to group related data, data which is likely to be updated at the same time and share the same metadata.

Datasets have a URI of the form `http://pmd.dev/data/<slug>`, for example `http://pmd.dev/data/my-first-dataset`. They have RDF type `http://publishmydata.com/def/dataset#Dataset` so you can find them with the SPARQL query:

```sparql
SELECT ?s
WHERE { ?s a <http://publishmydata.com/def/dataset#Dataset> }
```

Example Dataset: [Homelessness Acceptances 2011 Q2 to 2013 Q2, England, District By Ethnicity][odc-ha]

All the data for a dataset is stored in the graph `http://pmd.dev/graph/<slug>`, eg `http://pmd.dev/graph/my-first-dataset`, and all the metadata in `http://pmd.dev/graph/<slug>/metadata`, eg `http://pmd.dev/graph/my-first-dataset/metadata`.

The metadata of a Dataset is what is used to generate the description at the top of a Dataset page.

Metadata graphs are quite small, so you can easily dump the entire contents with:

```sparql
SELECT ?s ?p ?o
WHERE {
  GRAPH <http://opendatacommunities.org/graph/homelessness/homelessness-acceptances/ethnicity/metadata> {
    ?s ?p ?o
  }
}
```

You can also download it from "This dataset metadata is available as..." links at the bottom of a Dataset page

[odc-ha]: http://opendatacommunities.org/data/homelessness/homelessness-acceptances/ethnicity

## Data Cubes

Data Cubes are multi-dimensional datasets defined in the http://purl.org/linked-data/cube ontology (see below for Ontologies. Data Cubes contain Observations of type http://purl.org/linked-data/cube#Observation that relate to a Dataset. For example, the homelessness data set above has dimensions:

* Reference area
* Reference period http://opendatacommunities.org/def/ontology/time/refPeriod
* Ethnicity

Each Observation (ie each uniquely identified value when area, period and ethnicity are all specified), has a http://purl.org/linked-data/cube#dataSet property that points back to the PublishMyData Dataset.

## Geographic Data Cubes

This applies to Open Data Communities. A Geographic Data Cube is a Data Cube where one of the Dimensions is geographic. This is currently defined by the presensce of an observation with a geographic Dimension Property, rather than at the metadata level itself, so you can find them with the following (slow) query:

```sparql
SELECT DISTINCT ?dataset WHERE {
  ?dataset a <http://publishmydata.com/def/dataset#Dataset> .
  ?observation <http://purl.org/linked-data/cube#dataSet> ?dataset .
  ?observation <http://opendatacommunities.org/def/ontology/geography/refArea> ?area
}
```

## Ontologies

Ontologies are formal definitions of vocabularies and are defined using the Web Ontology Language ([OWL][owl]). OWL is based on RDF and so is also expressed as a set of triples.

For example, "Reference period" (http://opendatacommunities.org/def/ontology/time/refPeriod) is defined by (http://www.w3.org/2000/01/rdf-schema#isDefinedBy) "Vocabulary of terms related to time." (http://opendatacommunities.org/def/ontology/time).

One heuristic to find all data about ontologies (useful for priming an development database) is to ask for the contents of every graph where something is defined as an ontology:

```sparql
CONSTRUCT { ?s ?p ?o }
WHERE {
  GRAPH ?graph {
    ?ontology a <http://www.w3.org/2002/07/owl#Ontology> .
    ?s ?p ?o
  }
}
```

## Dimension Property

A property like "Reference period" is a http://purl.org/linked-data/cube#DimensionProperty and is used to indicate which properties of Observations are used to drill down to a grid view.

You can find all Dimension Properties and their defining ontology with:

```sparql
SELECT ?ontologyLabel ?ontology ?property ?label
WHERE {
  ?property a <http://purl.org/linked-data/cube#DimensionProperty> .
  OPTIONAL { ?property <http://www.w3.org/2000/01/rdf-schema#label> ?label } .
  ?property <http://www.w3.org/2000/01/rdf-schema#isDefinedBy> ?ontology .
  OPTIONAL { ?ontology <http://www.w3.org/2000/01/rdf-schema#label> ?ontologyLabel }
}
ORDER BY ?ontologyLabel ?ontology
```

RDF labels are used to give human-readable names to things. PublishMyData uses them extensively to fill in the link text on HTML pages. If you see a link which has text for the URI, it is probably because no http://www.w3.org/2000/01/rdf-schema#label property is defined for that resource.

[owl]: http://www.w3.org/2004/OWL/

## Measure Property

Measure Properties (http://purl.org/linked-data/cube#MeasureProperty) describe the observation and are the values at specific points in the cube. For example, in the Homelessness Acceptances dataset on Open Data Communities, the each Observation has a http://opendatacommunities.org/def/ontology/homelessness/homelessnessAcceptancesObs property (the number of homelessness acceptances, an integer).