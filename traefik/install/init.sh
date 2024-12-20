#!/usr/bin/env bash

primary_node=""
if [ "$STAGING" == "true" ]; then
  primary_node="emc-staging-01"
elif [ "$STAGING" == "false" ]; then
  primary_node="emc-01"
else
  echo "Invalid staging value: $STAGING"
  exit 1
fi

# Create namespace before helm chart so we can install the Cloudflare credentials
kubectl create namespace traefik

# Requires SOPS and age installed and the private key setup properly to work
sops --decrypt cloudflare-creds.enc.yaml | kubectl apply -f -

helm repo add traefik https://traefik.github.io/charts
helm repo update traefik

helm install traefik traefik/traefik --version 32.1.1 \
  -n traefik \
  --values values.yaml \
  --set nodeSelector."kubernetes\.io/hostname=$primary_node"

# Apply Kani
kubectl apply -f kani.yaml
