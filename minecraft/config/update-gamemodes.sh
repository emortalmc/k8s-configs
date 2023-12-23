#!/usr/bin/env bash

kubectl create configmap gamemodes \
  -n emortalmc --from-file=./gamemodes \
  --dry-run=client -o yaml | kubectl apply -f -
