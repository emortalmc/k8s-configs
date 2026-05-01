#!/usr/bin/env bash

helm repo add strimzi https://strimzi.io/charts/
helm repo update strimzi

helm install strimzi-kafka strimzi/strimzi-kafka-operator \
  --values values.yaml --version 0.43.0 \
  -n strimzi-system --create-namespace

#kubectl create -f 'https://strimzi.io/install/latest?namespace=emortalmc' -n emortalmc

#helm repo add lsstsqre https://lsst-sqre.github.io/charts/
#helm repo update lsstsqre

#helm install strimzi-registry-operator lsstsqre/strimzi-registry-operator \
#  --set "clusterName=default" \
#  --set "clusterNamespace=emortalmc" \
#  --set "operatorNamespace=emortalmc" \
#  --namespace emortalmc

# We're not using the schema registry right now
#kubectl apply -f schema-registry.yaml -n emortalmc
