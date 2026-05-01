resource "kubernetes_namespace" "reposilite" {
  metadata {
    name = "reposilite"
  }
}

resource "helm_release" "reposilite" {
  name       = "reposilite"
  repository = "https://helm.reposilite.com/"
  chart      = "reposilite"
  namespace  = kubernetes_namespace.reposilite.metadata[0].name
  version    = "1.3.12"

  create_namespace = false

  values = [
    file("files/reposilite-values.yaml")
  ]

  wait    = true
  atomic  = true
  timeout = 120
}