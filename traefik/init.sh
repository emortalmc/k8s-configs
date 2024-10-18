#!/usr/bin/env bash

# Modify Traefik Helm chart values
run_init_script install

# Install internal routes
run_script external generate.sh

# Install external routes
if [ "$STAGING" == "false" ]; then
  sed "s|{{host}}|emortal.dev|g" "./external/reposilite.yaml" | kubectl apply -f -
fi
