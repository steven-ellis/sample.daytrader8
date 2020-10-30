#!/bin/bash
set -e 

trap '{ echo "" ; exit 1; }' INT

KAFKA_CLUSTER_NS=${1:-'daytrader'}
KAFKA_CLUSTER_NAME=${2:-'daytrader'}
KAFKA_TOPIC=${3:-'daytrader.inventory.outboxevent'}

kubectl -n $KAFKA_CLUSTER_NS run kafka-producer -ti \
 --image=strimzi/kafka:0.15.0-kafka-2.3.1 \
 --rm=true \
 --restart=Never \
 -- bin/kafka-console-producer.sh \
 --broker-list $KAFKA_CLUSTER_NAME-kafka-bootstrap.$KAFKA_CLUSTER_NS:9092 \
 --topic $KAFKA_TOPIC
