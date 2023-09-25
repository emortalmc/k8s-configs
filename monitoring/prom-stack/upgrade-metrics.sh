helm upgrade prom-stack prometheus-community/kube-prometheus-stack \
  --values values.yaml --version 51.2.0 \
  -n monitoring
