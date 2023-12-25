locals {
  reposilite_url = "repo.emortal.dev"
  // TODO: Decide if we are actually going to use any of the subdomained ones or just unify them all
  argocd_url = var.production ? "argo.emortal.dev" : "argo.staging.emortal.dev"
  grafana_url = var.production ? "metrics.emortal.dev" : "metrics.staging.emortal.dev"
  traefik_url = var.production ? "traefik.emortal.dev" : "traefik.staging.emortal.dev"
  linkerd_url = var.production ? "linkerd.emortal.dev" : "linkerd.staging.emortal.dev"
}

resource "helm_release" "traefik" {
  name = "traefik"
  namespace = "traefik"

  repository = "https://traefik.github.io/charts"
  chart = "traefik"

  create_namespace = true
  version = "24.0.0"

  set {
    name  = "certResolvers.cloudflare.email"
    value = "certs@emortal.dev"
  }
  set {
    name  = "certResolvers.cloudflare.dnsChallenge.provider"
    value = "cloudflare"
  }
  set {
    name  = "certResolvers.cloudflare.dnsChallenge.delayBeforeCheck"
    value = "30"
  }
  set_list {
    name  = "certResolvers.cloudflare.dnsChallenge.resolvers"
    value = ["1.1.1.1", "8.8.8.8"]
  }
  set {
    name  = "certResolvers.cloudflare.storage"
    value = "/data/certs.json"
  }

  set {
    name  = "logs.general.level"
    value = "DEBUG"
  }

  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "persistence.name"
    value = "traefik"
  }

  set {
    name  = "envFrom[0].secretRef.name"
    value = "cloudflare-api"
  }
}

// Ingress routes

resource "kubernetes_manifest" "reposilite-ingress" {
  depends_on = [helm_release.reposilite]
  count = var.production ? 1 : 0

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
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

resource "kubernetes_manifest" "argocd-ingress" {
  depends_on = [helm_release.argocd, kubernetes_manifest.kani-middleware]

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
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
  depends_on = [helm_release.prom-stack, kubernetes_manifest.kani-middleware]

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
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
  depends_on = [helm_release.traefik, kubernetes_manifest.kani-middleware]

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
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
#    apiVersion = "traefik.io/v1alpha1"
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
#    apiVersion = "traefik.io/v1alpha1"
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
