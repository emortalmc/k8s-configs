helm repo add argo https://argoproj.github.io/argo-helm

kubectl apply -k "https://github.com/argoproj/argo-cd/manifests/crds?ref=v2.7.4"

helm install argocd argo/argo-cd --version 5.36.1  \
  --values values.yaml \
  -n argocd --create-namespace

