cloudflare_email=$1
cloudflare_dns_api_token=$2
staging=$3

primary_node=""
if [ $staging == "true" ]; then
  primary_node="emc-staging-01"
elif [ $staging == "false" ]; then
  primary_node="emc-01"
else
  echo "Invalid staging value: $staging"
  exit 1
fi

kubectl create secret generic cloudflare-api \
  --from-literal=CLOUDFLARE_EMAIL="$cloudflare_email" \
  --from-literal=CLOUDFLARE_DNS_API_TOKEN="$cloudflare_dns_api_token" \
  -n kube-system

cat helm-override.yaml | sed "s|{{node}}|$primary_node|g" | kubectl apply -f -
