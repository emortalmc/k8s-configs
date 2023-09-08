services=("permission-service" "relationship-manager" "mc-player-service" "player-tracker" "party-manager" "matchmaker")

for service in "${services[@]}"
do
  password=$(head -c 100 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
  cat ./template.yaml | sed "s|{{service}}|$service|g" | sed "s|{{password}}|$password|g" | kubectl apply -f -
done
