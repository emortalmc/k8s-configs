#!/usr/bin/env bash

helm repo add tailscale https://pkgs.tailscale.com/helmcharts
helm repo update tailscale

helm upgrade \
  --install \
  tailscale-operator \
  tailscale/tailscale-operator \
  --version 1.74.1 \
  --namespace=tailscale \
  --create-namespace \
  -f <(sops --decrypt values.enc.yaml) \
  --wait
