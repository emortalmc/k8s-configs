routes_prod=("argocd" "grafana" "linkerd" "traefik")
auds_prod=(
  "d6a87f3e3f7d2a2d54b50a7faa177f4146690992110679decf4ed403b5e80009"
  "d8d23f5bede65e1937c30377d952744306f0e38ba90b844ff437e371fec6f7d3"
  "c20c081e78a66d7e77888c4a2b1da0eb4382ba275a8e8a4118448510a81dc77a"
  "5d66ba76fa7d60bc32c6edb6645f42306cc6070c2991d7b99dea00163cbc5bac"
)

routes_staging=("argocd" "grafana" "traefik")
auds_staging=(
  "09082b8fda21182a02b5aba5fb60767895716de1a36072b370a92590f9060015"
  "1a56036f8605bf579a72279ed7489926f8afd92485b20a099bafdf1747f6601e"
  "651d6b7f07ced98d168bee23e1534bc7c9b50e30b869fb715b4aa929cca6fe49"
)

host=""
routes=
auds=
if [ "$STAGING" == "true" ]; then
  host="staging.emc.dev"
  routes=("${routes_staging[@]}")
  auds=("${auds_staging[@]}")
elif [ "$STAGING" == "false" ]; then
  host="emortal.dev"
  routes=("${routes_prod[@]}")
  auds=("${auds_prod[@]}")
else
  echo "staging must be true or false"
  exit 1
fi

for (( i=0; i<"${#routes[@]}"; i++ ))
do
  route="${routes[i]}"
  aud="${auds[i]}"
  cat "./$route.yaml" | sed "s|{{host}}|$host|g" | sed "s|{{aud}}|$aud|g" | kubectl apply -f -
done
