# Install Prometheus Stack & Monitoring stuff
run_script prom-stack install-metrics.sh

# Setup Grafana dashboards
kubectl apply -f ./grafana/dashboard/agones
kubectl apply -f ./grafana/dashboard/loki
kubectl apply -f ./grafana/dashboard/minecraft

# Setup monitors
kubectl apply -f ./monitors

# Add the Grafana repo here as Loki and Promtail need it
helm repo add grafana https://grafana.github.io/helm-charts
helm repo update grafana

# Install Loki
run_init_script loki

# Install Promtail
run_init_script promtail

# Install Pyroscope
run_init_script pyroscope
