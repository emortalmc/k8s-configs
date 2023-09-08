#!/usr/bin/env bash

# Install Agones
source ./agones/init.sh

# Install ArgoCD
source ./argocd/init.sh
kubectl apply -f ./argocd/emortalmc-project.yaml

source ./argocd/repos/generate.sh
source ./argocd/apps/generate.sh false

# Install Kafka
source install-operator.sh
kubectl apply -f ./kafka/cluster-config.yaml
kubectl apply -f ./kafka/topics

# Install game mode configs
source ./minecraft/config/update-gamemodes.sh

# Install MongoDB
source ./mongodb/init.sh
source ./mongodb/secrets/generate.sh
kubectl apply -f ./mongodb/database.yaml

# Install Prometheus Stack & Monitoring stuff
source ./monitoring/install/install-metrics.sh

kubectl apply -f ./grafana/dashboard/agones
kubectl apply -f ./grafana/dashboard/loki
kubectl apply -f ./grafana/dashboard/minecraft

kubectl apply -f ./agones/prom-service-monitor.yaml
kubectl apply -f ./minecraft/pod-monitor.yaml

# Install Loki and Promtail
source ./monitoring/loki/init.sh
kubectl apply -f ./monitoring/loki/grafana-datasource.yaml

source ./monitoring/promtail/init.sh

# Install Pyroscope
source ./monitoring/pyroscope/init.sh
kubectl apply -f ./monitoring/pyroscope/grafana-datasource.yaml
kubectl apply -f ./monitoring/pyroscope/config-maps.yaml

# Reposilite
source ./reposilite/init.sh

# Install the service accounts, roles, and role bindings
kubectl apply -f ./serviceaccounts
kubectl apply -f ./serviceaccounts/agones
kubectl apply -f ./serviceaccounts/roles

# Modify Traefik and install routes
cloudflare_email=
cloudflare_dns_api_token=
source ./traefik/install/init.sh $cloudflare_email $cloudflare_dns_api_token false

source ./traefik/internal/generate.sh false
kubectl apply -f ./traefik/external/reposilite.yaml
