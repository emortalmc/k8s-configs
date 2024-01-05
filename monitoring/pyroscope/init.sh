#!/usr/bin/env bash

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana

helm install pyroscope grafana/pyroscope \
  --namespace monitoring \
  --values ./values.yaml

kubectl apply -f ./grafana-datasource.yaml
kubectl apply -f ./config-maps.yaml
