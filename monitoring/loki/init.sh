helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana

helm install loki grafana/loki \
  --values values.yaml \
  -n monitoring
