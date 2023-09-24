helm repo add reposilite https://helm.reposilite.com/
helm repo update reposilite

helm install reposilite reposilite/reposilite \
  --values ./values.yaml --version 1.2.8 \
  -n reposilite --create-namespace
