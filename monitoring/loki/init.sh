#!/usr/bin/env bash

helm install loki grafana/loki \
  --values ./values.yaml \
  -n monitoring

kubectl apply -f ./grafana-datasource.yaml
