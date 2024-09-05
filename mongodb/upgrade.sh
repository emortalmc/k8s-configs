#!/usr/bin/env bash

helm upgrade mongodb-operator mongodb/community-operator \
  --version 0.8.0 \
  --values values.yaml \
  -n mongodb

# re-apply the database.yaml (includes all the databases and their paired secrets)
kubectl apply -f ./database.yaml