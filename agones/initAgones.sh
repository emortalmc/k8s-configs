kubectl create namespace emortalmc
helm repo add agones https://agones.dev/chart/stable
helm repo update agones
helm install agones agones/agones \
  --values values.yaml --version 1.31.0 \
  -n agones-system --create-namespace

FORWARDING_TOKEN=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9~!@#$%^&*_-' | fold -w 128 | head -n 1)
kubectl create secret generic velocity-forwarding-token --from-literal=forwarding.secret="$FORWARDING_TOKEN" -n emortalmc
