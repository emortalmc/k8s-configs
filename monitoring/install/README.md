# Grafana EmortalMC Install

## Install
```bash
kubectl create namespace monitoring
kubectl apply -f cloudflare-auth.yaml
helm install prom-stack -f values.yaml prometheus-community/kube-prometheus-stack -n monitoring
```
