#!/usr/bin/env bash

helm repo add nats https://nats-io.github.io/k8s/helm/charts/
helm repo update nats

helm install nats nats/nats -n emortalmc --version 1.2.4 --values ./values.yaml
