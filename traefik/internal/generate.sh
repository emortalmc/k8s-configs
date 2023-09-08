routes=("argocd" "grafana" "linkerd" "traefik")
staging=$1

host=""
if [ $staging == "true" ]; then
  host="emc.staging"
elif [ $staging == "false" ]; then
  host="emc"
else
  echo "staging must be true or false"
  exit 1
fi

for route in "${routes[@]}"
do
  echo "$(cat "$route.yaml" | sed "s|{{host}}|$host|g")"
done
