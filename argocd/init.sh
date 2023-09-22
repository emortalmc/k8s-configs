helm repo add argo https://argoproj.github.io/argo-helm
helm repo update argo

kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.7.4"

helm install argocd argo/argo-cd \
  --values ./values.yaml --version 5.36.1 \
  -n argocd --create-namespace

kubectl apply -f ./emortalmc-project.yaml

# Requires SOPS and age installed and the private key setup properly to work
sops --decrypt ./emortalmc-ssh-access.enc.yaml | kubectl apply -f -

# Run generators
run_script repos generate.sh
run_script apps generate.sh
