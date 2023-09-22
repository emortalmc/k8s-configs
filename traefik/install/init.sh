primary_node=""
if [ $STAGING == "true" ]; then
  primary_node="emc-staging-01"
elif [ $STAGING == "false" ]; then
  primary_node="emc-01"
else
  echo "Invalid staging value: $STAGING"
  exit 1
fi

# Requires SOPS and age installed and the private key setup properly to work
sops --decrypt cloudflare-creds.enc.yaml | kubectl apply -f -

# Override default Traefik Helm chart values
cat helm-override.yaml | sed "s|{{node}}|$primary_node|g" | kubectl apply -f -
