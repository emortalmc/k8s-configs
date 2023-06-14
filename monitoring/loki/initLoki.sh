helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana

helm install --values values.yaml loki grafana/loki -n monitoring