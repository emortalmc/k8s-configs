helm repo add pyroscope-io https://pyroscope-io.github.io/helm-chart
helm repo update pyroscope-io
helm install -f values.yaml pyroscope-io pyroscope-io/pyroscope -n pyroscope --create-namespace
