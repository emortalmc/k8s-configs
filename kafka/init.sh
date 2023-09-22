# Install Strimzi Kafka operator
source ./install-operator.sh

# Install Kafka cluster
kubectl apply -f ./cluster-config.yaml

# Install Kafka topics
kubectl apply -f ./topics
