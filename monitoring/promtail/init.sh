#!/usr/bin/env bash

helm install promtail grafana/promtail \
  --version 6.16.0 \
  --values values.yaml \
  -n monitoring
