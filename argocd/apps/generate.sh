servers=("battle" "blocksumo" "lazertag" "lobby" "marathon" "minesweeper" "parkourtag" "tower-defence")
services=("matchmaker" "mc-player-service" "message-handler" "party-manager" "permission-service" "relationship-manager" "game-tracker")

file=""
if [ "$STAGING" == "true" ]; then
  file="template-staging.yaml"
elif [ "$STAGING" == "false" ]; then
  file="template-prod.yaml"
else
  echo "staging must be true or false"
  exit 1
fi

for (( i=0; i<"${#servers[@]}"; i++ ))
do
  server="${servers[i]}"
  cat $file | sed "s|{{name}}|$server|g" | sed "s|{{path}}|server|g" | sed "s|{{values_path}}|values/$server.yaml|g" | kubectl apply -f -
done

for (( i=0; i<"${#services[@]}"; i++ ))
do
  service="${services[i]}"
  cat $file | sed "s|{{name}}|$service|g" | sed "s|{{path}}|service|g" | sed "s|{{values_path}}|values/$service.yaml|g" | kubectl apply -f -
done

# Velocity has its own Helm chart
cat $file | sed "s|{{name}}|velocity-core|g" | sed "s|{{path}}|velocity|g" | sed "s|{{values_path}}|values.yaml|g" | kubectl apply -f -
