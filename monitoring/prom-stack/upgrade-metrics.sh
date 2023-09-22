helm upgrade prom-stack prometheus-community/kube-prometheus-stack \
  --values values.yaml --version 50.3.1 \
  -n monitoring
