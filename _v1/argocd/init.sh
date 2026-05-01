#!/usr/bin/env bash

helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.12.5"

helm install argocd argo/argo-cd \
  --values ./values.yaml --version 7.6.11 \
  -n argocd --create-namespace

kubectl apply -f ./emortalmc-project.yaml

# Requires SOPS and age installed and the private key setup properly to work
sops --decrypt ./emortalmc-deployments-repo.enc.yaml | kubectl apply -f -

# Run generators
run_script apps generate.sh
