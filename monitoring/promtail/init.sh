#!/usr/bin/env bash

helm install promtail grafana/promtail \
  --values values.yaml \
  -n monitoring
