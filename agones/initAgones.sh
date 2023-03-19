kubectl create namespace emortalmc
helm repo add agones https://agones.dev/chart/stable
helm repo update agones
helm install agones agones/agones --set "gameservers.namespaces={emortalmc}" \
  --set "agones.allocator.service.http.enabled=false" \
  --set "agones.metrics.prometheusEnabled=true" \
  --set "agones.metrics.prometheusServiceDiscovery=true" \
  --set "agones.metrics.serviceMonitor.enabled=true" \
  --set "agones.allocator.serviceMetrics.http.portName=metrics" \
  --set "agones.featureGates=PlayerTracking=true&PlayerAllocationFilter=true" \
  --set "agones.controller.allocationBatchWaitTime=50ms" \
  -n agones-system --create-namespace

FORWARDING_TOKEN=$(cat /dev/urandom | fold -w 128 | head -n 1)
kubectl create secret generic velocity-forwarding-token --from-literal=forwarding.secret="$FORWARDING_TOKEN" -n emortalmc
