#!/usr/bin/env bash

primary_node="emc-01"
helm upgrade traefik traefik/traefik --version 24.0.0 \
  -n traefik \
  --values values.yaml \
  --set nodeSelector."kubernetes\.io/hostname=$primary_node"
