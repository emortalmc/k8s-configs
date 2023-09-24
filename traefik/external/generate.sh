routes=("argocd" "grafana" "linkerd" "traefik")

host=""
if [ "$STAGING" == "true" ]; then
  host="staging.emortal.dev"
elif [ "$STAGING" == "false" ]; then
  host="emortal.dev"
else
  echo "staging must be true or false"
  exit 1
fi

for route in "${routes[@]}"
do
  cat "./$route.yaml" | sed "s|{{host}}|$host|g" | kubectl apply -f -
done
