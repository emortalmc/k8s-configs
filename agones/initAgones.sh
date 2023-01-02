kubectl create namespace towerdefence
helm repo add agones https://agones.dev/chart/stable
helm repo update
helm install agones agones/agones --set "gameservers.namespaces={emortalmc}" \
  --set "agones.allocator.service.http.enabled=false" \
  --set "agones.allocator.service.grpc.enabled=false" \
  --set "agones.metrics.prometheusEnabled=true" \
  --set "agones.metrics.prometheusServiceDiscovery=true" \
  --set "agones.allocator.serviceMetrics.http.portName=metrics" \
  --set "agones.featureGates=PlayerTracking=true&PlayerAllocationFilter=true" \
  -n agones-system --create-namespace
