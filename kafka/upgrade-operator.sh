#!/usr/bin/env bash

helm upgrade strimzi-kafka strimzi/strimzi-kafka-operator \
  --values values.yaml --version 0.43.0 \
  -n strimzi-system
