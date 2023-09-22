kubectl create namespace monitoring

kubectl apply -f ./anonymous-auth.yaml

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update prometheus-community

helm install prom-stack prometheus-community/kube-prometheus-stack \
  --values ./values.yaml --version 50.3.1 \
  -n monitoring
