helm repo add mongodb https://mongodb.github.io/helm-charts

kubectl create namespace mongodb
helm install mongodb-operator mongodb/community-operator -n mongodb -f values.yaml
