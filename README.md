# Day Trader

## Pre-requisites

- OpenShift 4 Cluster
- Strimizi Kafka

## Prepare Cluster

## Deploy Databases

On clusters where heritage application `sampledaytrader` is deployed, deployed MySQL:

```shell script
oc apply -k k8s/db/mysql/prod
```

(Optional)

If you need Web based DB Console then run the following command on the clusters:

```shell script
oc apply -k k8s/db/adminer/prod
```

## Deploy Kafka

```shell script
oc apply -k k8s/kafka/prod
```

## Deploy Debezium KafkaConnect and MySQL KafkaConnector

```shell script
oc apply -k k8s/debezium/prod
```

__NOTE__: This will take few mins for the Connector to be activated

Wait for the KafkaConnect `daytrader-debezium-connect` pod to be running:

```shell script
watch oc get pods -l=strimzi.io/name=daytrader-debezium-connect
```

A successful KafkaConnect should show "Ready" to be "True":

```shell script
 oc get KafkaConnect daytrader-debezium -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}'
```

__NOTE__: It will take few seconds for the KafkaConnector to be reconciled. Wait for few mins before you run the following commands to check the status.

Check the status of the `mysql-daytrader-connector` to be ready:

```shell script
 oc get KafkaConnector mysql-daytrader-connector -ojsonpath='{.status.conditions[?(@.type=="Ready")].status}'
```

## Deploy Application

```shell script
oc apply -k k8s/sampledaytrader8/prod
```

```shell script
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

## List Kafka Topics

```shell script
./scripts/kafka-list-topics 
```
Will list the following topics, you should see one topic per table of the DB with prefix `openshift.inventory.`.

```text
__consumer_offsets
connect-cluster-configs
connect-cluster-offsets
connect-cluster-status
openshift
openshift.traderdb.accountejb
openshift.traderdb.accountprofileejb
openshift.traderdb.holdingejb
openshift.traderdb.keygenejb
openshift.traderdb.orderejb
openshift.traderdb.quoteejb
schema-changes.traderdb
```

## Access the Application

```shell script
$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/
```

## Development

### Building Debezium MySql Connector 

```shell script
cd k8s/debezium
docker build --no-cache <container-registry>/debezium-connect
docker push <container-registry>/debezium-connect
```

__NOTE__: Be sure to update the k8s/debezium/debezium-connect.yaml with image image from the build

### Image Streams

```shell script
oc create -f https://raw.githubusercontent.com/OpenLiberty/open-liberty-s2i/master/imagestreams/openliberty-ubi-min.json
```

### Deploy Application

```shell script
oc new-app openliberty:~https://github.com/kameshsampath/sample.daytrader8#sko-demo -n daytrader-dev
```

```shell script
oc create route edge --service=sampledaytrader8 --port=9080 daytrader
export DAYTRADER_ROUTE="https://$(oc get route daytrader -ojsonpath='{.spec.host}')"
```