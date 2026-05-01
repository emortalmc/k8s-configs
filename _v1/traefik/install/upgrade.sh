#!/usr/bin/env bash

primary_node="emc-02"
helm upgrade traefik traefik/traefik --version 32.1.1 \
  -n traefik \
  --values values.yaml \
  --set nodeSelector."kubernetes\.io/hostname=$primary_node"
