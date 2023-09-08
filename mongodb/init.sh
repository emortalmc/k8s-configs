helm repo add mongodb https://mongodb.github.io/helm-charts

kubectl create namespace mongodb
helm install mongodb-operator mongodb/community-operator \
  --values values.yaml \
  -n mongodb
