#!/usr/bin/env bash

helm upgrade pyroscope grafana/pyroscope \
  --version 1.9.1 \
  --namespace monitoring \
  --values ./values.yaml
