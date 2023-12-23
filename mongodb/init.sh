#!/usr/bin/env bash

kubectl create namespace mongodb

helm repo add mongodb https://mongodb.github.io/helm-charts
helm repo update mongodb

# Install community operator
helm install mongodb-operator mongodb/community-operator \
  --version 0.8.0 \
  --values values.yaml \
  -n mongodb

# Generate database secrets
run_script secrets generate.sh

# Install database
kubectl apply -f ./database.yaml
