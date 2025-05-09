#!/usr/bin/env bash

kubectl create namespace emortalmc

helm repo add agones https://agones.dev/chart/stable
helm repo update agones

helm install agones agones/agones \
  --values ./values.yaml --version 1.44.0 \
  -n agones-system --create-namespace

# TODO we should figure out a proper way to do CRDs for Agones

forwarding_token=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | fold -w 128 | head -n 1)
routing_token=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | fold -w 128 | head -n 1)
kubectl create secret generic velocity-forwarding-token --from-literal=forwarding.secret="$forwarding_token" -n emortalmc
kubectl create secret generic edge-routing-token --from-literal=routing-token="$routing_token" -n emortalmc
