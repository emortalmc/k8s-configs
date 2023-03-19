kubectl create -f 'https://strimzi.io/install/latest?namespace=emortalmc' -n emortalmc

helm repo add lsstsqre https://lsst-sqre.github.io/charts/
helm repo update lsstsqre

helm install strimzi-registry-operator lsstsqre/strimzi-registry-operator \
  --set "clusterName=default" \
  --set "clusterNamespace=emortalmc" \
  --set "operatorNamespace=emortalmc" \
  -n emortalmc

kubectl apply -f schema-registry.yaml -n emortalmc