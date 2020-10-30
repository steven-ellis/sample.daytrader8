#!/bin/bash

set -eu

PROFILE_NAME=${PROFILE_NAME:-debezium-tutorial}
MEMORY=${MEMORY:-8192}
CPUS=${CPUS:-6}

minikube start -p $PROFILE_NAME \
  --memory=$MEMORY \
  --cpus=$CPUS \
  --disk-size=50g \
  --insecure-registry='10.0.0.0/24' 
