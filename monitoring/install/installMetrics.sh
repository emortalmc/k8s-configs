kubectl apply -f anonymous-auth.yaml

helm install prom-stack prometheus-community/kube-prometheus-stack \
  --values values.yaml --version 46.6.0 \
  -n monitoring --create-namespace
