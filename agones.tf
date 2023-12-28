resource "helm_release" "agones" {
  depends_on = [kubernetes_namespace.emortalmc]

  name      = "agones"
  namespace = "agones-system"

  repository = "https://agones.dev/chart/stable"
  chart      = "agones"

  create_namespace = true
  version          = "1.34.0"

  values = [file("${path.module}/values/agones.yaml")]
}
