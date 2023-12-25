#!/usr/bin/env bash

# We might also want to do some more complex things that we'll figure out later.

# NOTE: This must be run on the system of the cluster

source ~/.bashrc

mkdir -p linkerdwork
cd linkerdwork || exit

helm repo add linkerd https://helm.linkerd.io/stable
helm repo update linkerd

helm install linkerd-crds linkerd/linkerd-crds \
  -n linkerd --create-namespace

# Install Step CLI

wget https://dl.smallstep.com/gh-release/cli/docs-cli-install/v0.24.4/step-cli_0.24.4_amd64.deb
sudo dpkg -i step-cli_0.24.4_amd64.deb

# Generate

step certificate create root.linkerd.cluster.local ca.crt ca.key \
--profile root-ca --no-password --insecure

step certificate create identity.linkerd.cluster.local issuer.crt issuer.key \
--profile intermediate-ca --not-after 8760h --no-password --insecure \
--ca ca.crt --ca-key ca.key

helm install linkerd-control-plane \
  -n linkerd \
  --set-file identityTrustAnchorsPEM=ca.crt \
  --set-file identity.issuer.tls.crtPEM=issuer.crt \
  --set-file identity.issuer.tls.keyPEM=issuer.key \
  linkerd/linkerd-control-plane

helm install linkerd-viz linkerd/linkerd-viz \
  -n linkerd

# Change back into the directory we were in
cd ..
# Remove the directory we created
rm -rf linkerdwork
