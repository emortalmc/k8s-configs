#!/usr/bin/env bash

source ./utils.sh
export STAGING=true

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

# Install Redis - disabled for now
#run_init_script redis

# Install the service accounts, roles, and role bindings
run_init_script 00-serviceAccounts

# Modify Traefik and install routes
run_init_script traefik
