#!/usr/bin/env bash

source ./utils.sh
export STAGING=false

# Install Agones
run_init_script agones

# Install ArgoCD
run_init_script argocd

# Install Kafka
run_init_script kafka

# Install game mode configs
run_init_script minecraft

# Install MongoDB
run_init_script mongodb

# Setup monitoring tools
run_init_script monitoring

# Install Redis - disabled for now as nothing uses Redis
#run_init_script redis

# Reposilite
run_init_script reposilite

# Install the service accounts, roles, and role bindings
run_init_script 00-serviceAccounts

# Modify Traefik and install routes
run_init_script traefik

# Install Tailscale
run_init_script tailscale
