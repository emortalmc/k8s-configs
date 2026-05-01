resource "kubernetes_namespace" "agones" {
  metadata {
    name = "agones-system"
  }
}

resource "helm_release" "agones" {
  name       = "agones"
  repository = "https://agones.dev/chart/stable"
  chart      = "agones"
  namespace  = kubernetes_namespace.agones.metadata[0].name
  version    = "1.44.0"

  create_namespace = false

  values = [
    file("files/agones-values.yaml")
  ]

  wait    = true
  atomic  = true
  timeout = 120
}