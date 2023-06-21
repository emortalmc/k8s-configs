resource "helm_release" "reposilite" {
  count = var.production ? 1 : 0 // Only deploy on production - we don't need 2 repositories

  name      = "reposilite"
  namespace = "reposilite"

  repository = "https://helm.reposilite.com"
  chart      = "reposilite"

  create_namespace = true

  set {
    name  = "resources.requests.memory"
    value = "128Mi"
  }
  set {
    name  = "resources.limits.memory"
    value = "256Mi"
  }
  set {
    name  = "persistence.size"
    value = "50Gi"
  }
}
