# This file should be run after initAgones.sh

kubectl create secret generic mongo-connection-string --from-literal=connectionString.standard=mongodb://host.minikube.internal:27017 -n emortalmc