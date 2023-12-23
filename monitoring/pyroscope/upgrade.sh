#!/usr/bin/env bash

helm upgrade pyroscope-io pyroscope-io/pyroscope \
  --values values.yaml \
  -n pyroscope --create-namespace
