#!/usr/bin/env bash

node_name=$1
address=$2

token=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9~@^&*_-' | fold -w 128 | head -n 1)

verify_variable_provided() {
  if [ -z "$1" ]; then
    echo "$2 not provided"
    exit 1
  fi
}

verify_variable_provided "$node_name" "Node name"
verify_variable_provided "$address" "Address"

hostnamectl set-hostname "$node_name"

# All systems are installed with Ubuntu so setting resolv.conf is necessary
curl -sfL https://get.k3s.io | K3S_TOKEN="$token" sh -s - server \
  --flannel-backend=wireguard-native \
  --advertise-address "$address" \
  --node-name "$node_name" \
  --node-ip "$address" \
  --resolv-conf /run/systemd/resolve/resolv.conf \
  --disable traefik

./init-common.sh

# Install Linkerd as it must be run on the server

source ~/.bashrc # Reload the bashrc file to get the KUBECONFIG variable from init-common.sh
./linkerd-setup.sh
