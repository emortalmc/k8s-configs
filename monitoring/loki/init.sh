#!/usr/bin/env bash

helm install loki grafana/loki \
  --version 6.18.0 \
  --values ./values.yaml \
  -n monitoring

kubectl apply -f ./grafana-datasource.yaml
