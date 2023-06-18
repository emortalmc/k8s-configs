helm repo add strimzi https://strimzi.io/charts/
helm repo update strimzi

helm install strimzi-kafka strimzi/strimzi-kafka-operator \
  --values 01-values.yaml \
  -n strimzi-system --create-namespace

#kubectl create -f 'https://strimzi.io/install/latest?namespace=emortalmc' -n emortalmc

#helm repo add lsstsqre https://lsst-sqre.github.io/charts/
#helm repo update lsstsqre

#helm install strimzi-registry-operator lsstsqre/strimzi-registry-operator \
#  --set "clusterName=default" \
#  --set "clusterNamespace=emortalmc" \
#  --set "operatorNamespace=emortalmc" \
#  -n emortalmc

# We're not using the schema registry right now
#kubectl apply -f schema-registry.yaml -n emortalmc
