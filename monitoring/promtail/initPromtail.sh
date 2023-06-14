helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana

helm install --values values.yaml promtail grafana/promtail -n monitoring