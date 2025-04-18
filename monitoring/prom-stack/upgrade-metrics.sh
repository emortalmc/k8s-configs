#!/usr/bin/env bash

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

helm upgrade prom-stack prometheus-community/kube-prometheus-stack \
  --values values.yaml --version 65.3.1 \
  -n monitoring
