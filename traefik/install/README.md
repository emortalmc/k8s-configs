# Traefik EmortalMC Install

## Install
Create the namespace. We need to make a secret in a second:
```bash
kubectl create namespace traefik-system
```

Create the cloudflare API token secret (must be created with Zone read and DNS edit):
```bash
kubectl create secret generic cloudflare-api --from-literal=CLOUDFLARE_EMAIL=<email> --from-literal=CLOUDFLARE_DNS_API_TOKEN=<api_key> -n traefik-system
```

Install Traefik using Helm:
```bash
helm install traefik traefik/traefik -f values.yaml -n traefik-system
```
