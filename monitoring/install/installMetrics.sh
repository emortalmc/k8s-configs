kubectl apply -f anonymous-auth.yaml

helm install prom-stack prometheus-community/kube-prometheus-stack \
  --values values.yaml --version 50.3.1 \
  -n monitoring --create-namespace
