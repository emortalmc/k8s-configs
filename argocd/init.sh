helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.7.4"

helm install argocd argo/argo-cd \
  --values values.yaml --version 5.36.1 \
  -n argocd --create-namespace
