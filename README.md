# Day Trader

## Pre-requisites

## Prepare Cluster

## Deploy Databases

```shell script
oc apply -k k8s/db
```

## Deploy Kafka

```shell script
oc apply -k k8s/kafka
```

## Image Streams

```shell script
oc create -f https://raw.githubusercontent.com/OpenLiberty/open-liberty-s2i/master/imagestreams/openliberty-ubi-min.json -n openshift
```

## Deploy Application

```shell script
oc new-app openliberty:~https://github.com/kameshsampath/sample.daytrader8#sko-demo -n daytrader-dev
```

```shell script
oc create route edge --service=sampledaytrader8 --port=9080 daytrader
export DAYTRADER_ROUTE="https://$(oc get route daytrader -ojsonpath='{.spec.host}')"
```

## Create and Populate the DB tables

```shell script
curl -X GET "$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/config?action=buildDBTables"
```

```shell script
oc scale --replicas=0 deploy/sampledaytrader8
oc scale --replicas=1 deploy/sampledaytrader8
```

```shell script
curl -X GET "$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/config?action=buildDB"
```

## Create Debezium Connectors

```shell script
oc apply -k k8s/debezium
```

## Access the Applcation

$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/