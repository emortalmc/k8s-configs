#!/usr/bin/env bash

helm upgrade agones agones/agones \
  --values values.yaml --version 1.42.0 \
  -n agones-system
