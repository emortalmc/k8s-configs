#!/usr/bin/env bash

# Set fs.inotify.max_user_instances (default is 128) to prevent "too many open files" error
echo "fs.inotify.max_user_instances=8192" >> /etc/sysctl.conf
echo "fs.inotify.max_user_watches=524288" >> /etc/sysctl.conf
echo "vm.max_map_count=1677720" >> /etc/sysctl.conf # Recommended by MongoDB
sysctl -p # Update sysctl

# Install Helm
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh

echo "
# EmortalMC Additions Start
export KUBECONFIG=/etc/rancher/k3s/k3s.yaml
# EmortalMC Additions End" >> ~/.bashrc
KUBECONFIG=/etc/rancher/k3s/k3s.yaml

source ~/.bashrc

# Add our SSH keys

mkdir -p ~/.ssh
for file in ./sshKeys/*; do
  cat "$file"; echo >> ~/.ssh/authorized_keys
done
