#!/usr/bin/env bash

helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami

helm install redis bitnami/redis \
  --values ./values.yaml --version 18.1.0 \
  -n emortalmc
