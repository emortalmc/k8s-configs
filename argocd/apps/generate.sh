#!/usr/bin/env bash

servers=("battle" "blocksumo" "lazertag" "lobby" "marathon" "minesweeper" "parkourtag" "tower-defence")
services=("matchmaker" "mc-player-service" "message-handler" "party-manager" "permission-service" "relationship-manager" "game-tracker" "game-player-data")

file=""
if [ "$STAGING" == "true" ]; then
  file="template-staging.yaml"
elif [ "$STAGING" == "false" ]; then
  file="template-prod.yaml"
else
  echo "staging must be true or false"
  exit 1
fi

generate() {
  sed "s|{{name}}|$2|g" "$1" | sed "s|{{path}}|$3|g" | sed "s|{{values_path}}|$4|g" | kubectl apply -f -
}

for (( i=0; i<"${#servers[@]}"; i++ ))
do
  server="${servers[i]}"
  generate "$file" "$server" "server" "values/$server.yaml"
done

for (( i=0; i<"${#services[@]}"; i++ ))
do
  service="${services[i]}"
  generate "$file" "$service" "service" "values/$service.yaml"
done

# Velocity has its own Helm chart
generate "$file" "velocity-core" "velocity" "values.yaml"
