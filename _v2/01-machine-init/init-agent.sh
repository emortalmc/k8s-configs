#!/usr/bin/env bash

control_server_ip=$1
token=$2

curl -sfL "https://get.k3s.io" | K3S_URL="https://$control_server_ip:6443" K3S_TOKEN="$token" sh -s - \
  --resolv-conf /run/systemd/resolve/resolv.conf \
  --disable traefik

./init-common.sh
