#!/usr/bin/env bash

helm upgrade pyroscope grafana/pyroscope \
  --namespace monitoring \
  --values ./values.yaml
