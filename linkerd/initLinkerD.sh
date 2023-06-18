# TODO in the future we should swap to the helm chart, I just don't wanna generate certs right now.
# We might also want to do some more complex things that we'll figure out later.

# NOTE: This must be run on the system of the cluster

curl --proto '=https' --tlsv1.2 -sSfL https://run.linkerd.io/install | sh
export PATH=$PATH:/root/.linkerd2/bin

# Set to k3s kubeconfig path
export KUBECONFIG="/etc/rancher/k3s/k3s.yaml"

linkerd check --pre

linkerd install --crds | kubectl apply -f -
linkerd install | kubectl apply -f -

linkerd check
