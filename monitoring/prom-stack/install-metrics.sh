#!/usr/bin/env bash

kubectl create namespace monitoring

kubectl apply -f ./cloudflare-auth.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

helm install prom-stack prometheus-community/kube-prometheus-stack \
  --values ./values.yaml --version 51.2.0 \
  -n monitoring
