CLOUDFLARE_EMAIL_VAL=
CLOUDFLARE_DNS_API_TOKEN_VAL=
kubectl create secret generic cloudflare-api --from-literal=CLOUDFLARE_EMAIL="$CLOUDFLARE_EMAIL_VAL" \
  --from-literal=CLOUDFLARE_DNS_API_TOKEN="$CLOUDFLARE_DNS_API_TOKEN_VAL" -n kube-system
