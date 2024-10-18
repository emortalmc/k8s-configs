#!/usr/bin/env bash

services=("permission-service" "relationship-manager" "mc-player-service" "player-tracker" "party-manager" "matchmaker" "game-tracker" "game-player-data")

for service in "${services[@]}"
do
  password=$(head -c 500 /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 32 | head -n 1)
  sed "s|{{service}}|$service|g" "template.yaml" | sed "s|{{password}}|$password|g" | kubectl apply -f -
done

# Create master password

password=$(head -c 1000 /dev/urandom | tr -dc 'a-zA-Z0-9!@#$%^&*()' | fold -w 64 | head -n 1)
kubectl create secret generic mongodb-master-password --from-literal=password=$password --from-literal=username=mongodb -n emortalmc
