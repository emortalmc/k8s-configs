helm repo add pyroscope-io https://pyroscope-io.github.io/helm-chart
helm repo update pyroscope-io

helm install pyroscope-io pyroscope-io/pyroscope \
  --values ./values.yaml \
  -n pyroscope --create-namespace

kubectl apply -f ./grafana-datasource.yaml
kubectl apply -f ./config-maps.yaml
