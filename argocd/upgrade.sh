helm upgrade argocd argo/argo-cd \
  --values ./values.yaml --version 7.6.11 \
  -n argocd