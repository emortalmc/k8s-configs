locals {
  reposilite_url = "repo.emortal.dev"
  argocd_url = var.production ? "argo.emc" : "argo.emc.staging"
  grafana_url = var.production ? "metrics.emc" : "metrics.emc.staging"
  traefik_url = var.production ? "traefik.emc" : "traefik.emc.staging"
  linkerd_url = var.production ? "linkerd.emc" : "linkerd.emc.staging"
}

resource "kubernetes_manifest" "traefik-helm-override" {
  manifest = {
    apiVersion = "helm.cattle.io/v1"
    kind       = "HelmChartConfig"

    metadata = {
      name      = "traefik"
      namespace = "kube-system"
    }

    spec = {
      valuesContent = templatefile("${path.module}/templates/traefik-helm-override.tftpl", { production = var.production })
    }
  }
}

// External Ingress routes

resource "kubernetes_manifest" "reposilite-ingress" {
  depends_on = [helm_release.reposilite]
  count = var.production ? 1 : 0

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "reposilite-ingress"
      namespace = "reposilite"
    }

    spec = {
      entryPoints = ["websecure"]
      routes      = [
        {
          match    = "Host(`${local.reposilite_url}`)"
          kind     = "Rule"
          services = [
            {
              name = "reposilite"
              port = "http"
            }
          ]
        }
      ]
    }
  }
}

// Internal Ingress routes

resource "kubernetes_manifest" "argocd-ingress" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "argocd-ingress"
      namespace = "argocd"
    }

    spec = {
      entryPoints = ["web"]
      routes      = [
        {
          match    = "Host(`${local.argocd_url}`)"
          kind     = "Rule"
          services = [
            {
              name = "argocd-server"
              port = "80"
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "grafana-ingress" {
  depends_on = [helm_release.prom-stack]

  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "grafana-ingress"
      namespace = "monitoring"
    }

    spec = {
      entryPoints = ["web"]
      routes      = [
        {
          match    = "Host(`${local.grafana_url}`)"
          kind     = "Rule"
          services = [
            {
              name = "prom-stack-grafana"
              port = "80"
            }
          ]
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "traefik-ingress" {
  manifest = {
    apiVersion = "traefik.containo.us/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "traefik-ingress"
      namespace = "kube-system"
    }

    spec = {
      entryPoints = ["web"]
      routes      = [
        {
          match    = "Host(`${local.traefik_url}`)"
          kind     = "Rule"
          services = [
            {
              name = "api@internal"
              kind = "TraefikService"
            }
          ]
        }
      ]
    }
  }
}

// Linkerd Ingress & Middleware

#resource "kubernetes_manifest" "linkerd-ingress" {
#  manifest = {
#    apiVersion = "traefik.containo.us/v1alpha1"
#    kind       = "IngressRoute"
#
#    metadata = {
#      name      = "linkerd-ingress"
#      namespace = "linkerd-viz"
#    }
#
#    spec = {
#      entryPoints = ["web"]
#      routes      = [
#        {
#          match    = "Host(`${local.linkerd_url}`)"
#          kind     = "Rule"
#          services = [
#            {
#              name = "web"
#              port = 8084
#            }
#          ]
#          middleware = [
#            {
#              name = "linkerd-header"
#            }
#          ]
#        }
#      ]
#    }
#  }
#}
#
#resource "kubernetes_manifest" "linkerd-header-middleware" {
#  manifest = {
#    apiVersion = "traefik.containo.us/v1alpha1"
#    kind       = "Middleware"
#
#    metadata = {
#      name      = "linkerd-header"
#      namespace = "linkerd-viz"
#    }
#
#    spec = {
#      headers = {
#        customRequestHeaders = {
#          Host   = "web.linkerd-viz.svc.cluster.local:8084"
#          Origin = ""
#        }
#      }
#    }
#  }
#}
