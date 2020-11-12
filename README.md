# Day Trader

## Pre-requisites

## Prepare Cluster

### Create DayTrader project

```shell script
oc new-project daytrader-dev
```

## Deploy Databases

On clusters where MySQL DB is required

```shell script
oc apply -k k8s/db/mysql
```
Login into the MySQL Database as root user the execute the following privileges SQL:

```sql
CREATE USER IF NOT EXISTS 'debezium'@'%' IDENTIFIED BY 'debezium';

CREATE USER IF NOT EXISTS 'replicator'@'%' IDENTIFIED BY 'replpass';

GRANT REPLICATION SLAVE, REPLICATION CLIENT ON *.* TO 'replicator'@'%';

CREATE USER IF NOT EXISTS 'debezium'@'%' IDENTIFIED BY 'debezium';

GRANT SELECT, RELOAD, SHOW DATABASES, REPLICATION SLAVE, REPLICATION CLIENT  ON *.* TO 'debezium'@'%';

CREATE DATABASE IF NOT EXISTS inventory;
CREATE DATABASE IF NOT EXISTS traderdb;

GRANT ALL PRIVILEGES ON inventory.* TO 'debezium'@'%';

GRANT ALL PRIVILEGES ON traderdb.* TO 'debezium'@'%';
```

On clusters where PostgreSQL is required

```shell script
oc apply -k k8s/db/postgresql
```

(Optional)

If you need Web based DB Console then run the following command on the clusters:

```shell script
oc apply -k k8s/db
```

## Deploy Kafka

```shell script
oc apply -k k8s/kafka
```

## Deploy Debezium KafkaConnect and MySQL KafkaConnector

```shell script
oc apply -k k8s/debezium
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

## Image Streams

```shell script
oc create -f https://raw.githubusercontent.com/OpenLiberty/open-liberty-s2i/master/imagestreams/openliberty-ubi-min.json
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
daytrader.inventory.outboxevent
openshift
openshift.inventory.accountejb
openshift.inventory.accountprofileejb
openshift.inventory.holdingejb
openshift.inventory.keygenejb
openshift.inventory.orderejb
openshift.inventory.outboxevent
openshift.inventory.quoteejb
schema-changes.inventory
```

## Access the Application

$DAYTRADER_ROUTE/io.openliberty.sample.daytrader8/