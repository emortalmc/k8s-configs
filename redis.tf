resource "helm_release" "redis" {
  depends_on = [kubernetes_namespace.emortalmc]

  name      = "redis"
  namespace = "emortalmc"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"

  set {
    name  = "nameOverride"
    value = "redis"
  }

  set {
    # We might enable the auth for additional security in the future, however, it isn't explicitly necessary.
    name  = "auth.enabled"
    value = "false"
  }
  set {
    name  = "auth.sentinel"
    value = "false"
  }

  set {
    name  = "replica.replicaCount"
    value = "2"
  }
}
