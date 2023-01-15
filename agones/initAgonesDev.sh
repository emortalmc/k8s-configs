# This file should be run after initAgones.sh

kubectl create secret generic rabbitmq-credentials --from-literal=host=host.minikube.internal \
  --from-literal=username=guest --from-literal=password=guest -n emortalmc

kubectl create secret generic mongo-connection-string --from-literal=connectionString.standard=mongodb://host.minikube.internal:27017 -n emortalmc