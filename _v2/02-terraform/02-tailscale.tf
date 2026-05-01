resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
  }
}

resource "helm_release" "tailscale" {
  name       = "tailscale-operator"
  repository = "https://pkgs.tailscale.com/helmcharts"
  chart      = "tailscale-operator"
  namespace  = kubernetes_namespace.tailscale.metadata[0].name
  version    = "1.96.5"

  create_namespace = false

  values = [
    yamlencode({
      apiServerProxyConfig = {
        mode = "true"
      }
    })
  ]

  set_sensitive {
    name  = "oauth.clientId"
    value = data.sops_file.secrets.data["tailscale_client_id"]
  }

  set_sensitive {
    name  = "oauth.clientSecret"
    value = data.sops_file.secrets.data["tailscale_client_secret"]
  }

  wait    = true
  atomic  = true
  timeout = 120
}
