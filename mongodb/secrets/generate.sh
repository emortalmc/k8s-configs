#!/usr/bin/env bash

services=("permission-service" "relationship-manager" "mc-player-service" "player-tracker" "party-manager" "matchmaker" "game-tracker")

for service in "${services[@]}"
do
  password=$(head -c 100 /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1)
  sed "s|{{service}}|$service|g" "template.yaml" | sed "s|{{password}}|$password|g" | kubectl apply -f -
done
