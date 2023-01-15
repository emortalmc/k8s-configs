helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update bitnami

# auth.enabled=false -> We might enable the auth for additional security in the future, however, it isn't explicitly necessary.
# replica.replicaCount=2 -> Default is 3, we don't need that many replicas.
helm install redis bitnami/redis -n emortalmc --set "auth.enabled=false" \
  --set "auth.sentinel=false" \
  --set "replica.replicaCount=2" \
  --set "nameOverride=redis"