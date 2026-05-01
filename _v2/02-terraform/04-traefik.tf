resource "kubernetes_namespace" "traefik" {
  metadata {
    name = "traefik"
  }
}

resource "kubernetes_secret" "cloudflare_creds" {
  metadata {
    name      = "cloudflare-creds"
    namespace = kubernetes_namespace.traefik.metadata[0].name
  }

  type = "Opaque"

  data = {
    CF_API_EMAIL    = data.sops_file.secrets.data["cloudflare_email"]
    CF_DNS_API_TOKEN = data.sops_file.secrets.data["cloudflare_api_token"]
  }
}

resource "helm_release" "traefik" {
  name       = "traefik"
  repository = "https://traefik.github.io/charts"
  chart      = "traefik"
  namespace  = kubernetes_namespace.traefik.metadata[0].name
  version    = "32.1.1"

  create_namespace = false

  values = [
    file("files/traefik-values.yaml")
  ]

  set {
    name  = "nodeSelector.kubernetes\\.io/hostname"
    value = "emc-01"
  }

  wait    = true
  atomic  = true
  timeout = 120
}

resource "kubectl_manifest" "kani" {
  yaml_body = file("files/kani.yaml")

  depends_on = [helm_release.traefik]
}

# Ingress Routes

locals {
  ingress_routes = {
    argocd = {
      namespace    = "argocd"
      subdomain    = "argo"
      service_name = "argocd-server"
      service_port = 80
      audience     = "d6a87f3e3f7d2a2d54b50a7faa177f4146690992110679decf4ed403b5e80009"
    }
    grafana = {
      namespace    = "monitoring"
      subdomain    = "metrics"
      service_name = "prom-stack-grafana"
      service_port = 80
      audience     = "d8d23f5bede65e1937c30377d952744306f0e38ba90b844ff437e371fec6f7d3"
    }
    traefik = {
      namespace    = "traefik"
      subdomain    = "traefik"
      service_name = "api@internal"
      service_kind = "TraefikService"
      audience     = "5d66ba76fa7d60bc32c6edb6645f42306cc6070c2991d7b99dea00163cbc5bac"
    }
    reposilite = {
      namespace    = "reposilite"
      subdomain    = "repo"
      service_name = "reposilite"
      service_port = "http"
    }
  }

  # Routes that need kani middleware
  kani_routes = { for k, v in local.ingress_routes : k => v if lookup(v, "audience", null) != null }
}

# Kani middleware (one per protected route)
resource "kubernetes_manifest" "kani_middleware" {
  for_each = local.kani_routes

  field_manager {
    force_conflicts = true
  }

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "kani-${each.key}-middleware"
      namespace = each.value["namespace"]
    }

    spec = {
      forwardAuth = {
        address              = "http://kani.traefik.svc.cluster.local/${each.value["audience"]}"
        authResponseHeaders  = ["X-Auth-User"]
      }
    }
  }
}

# IngressRoutes
resource "kubernetes_manifest" "ingress_route" {
  for_each = local.ingress_routes

  field_manager {
    force_conflicts = true
  }

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "${each.key}-ingress"
      namespace = each.value["namespace"]
    }

    spec = {
      entryPoints = ["websecure"]

      tls = {
        certResolver = "cloudflare"
      }

      routes = [
        {
          match = "Host(`${each.value["subdomain"]}.${var.base_domain}`)"
          kind  = "Rule"
          services = [
            merge(
              { name = each.value["service_name"] },
                lookup(each.value, "service_port", null) != null ? { port = each.value["service_port"] } : {},
                lookup(each.value, "service_kind", null) != null ? { kind = each.value["service_kind"] } : {},
            )
          ]
          middlewares = lookup(each.value, "audience", null) != null ? [
            { name = "kani-${each.key}-middleware" }
          ] : []
        }
      ]
    }
  }

  depends_on = [kubernetes_manifest.kani_middleware]
}

# LinkerD - handled separately due to extra middleware

resource "kubernetes_manifest" "kani_linkerd_middleware" {

  field_manager {
    force_conflicts = true
  }

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "kani-linkerd-middleware"
      namespace = "linkerd-viz"
    }

    spec = {
      forwardAuth = {
        address             = "http://kani.traefik.svc.cluster.local/c20c081e78a66d7e77888c4a2b1da0eb4382ba275a8e8a4118448510a81dc77a"
        authResponseHeaders = ["X-Auth-User"]
      }
    }
  }
}

resource "kubernetes_manifest" "l5d_header_middleware" {

  field_manager {
    force_conflicts = true
  }

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "Middleware"

    metadata = {
      name      = "l5d-header"
      namespace = "linkerd-viz"
    }

    spec = {
      headers = {
        customRequestHeaders = {
          Host   = "web.linkerd-viz.svc.cluster.local:8084"
          Origin = ""
        }
      }
    }
  }
}

resource "kubernetes_manifest" "l5d_ingress_route" {

  field_manager {
    force_conflicts = true
  }

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind       = "IngressRoute"

    metadata = {
      name      = "l5d-ingress"
      namespace = "linkerd-viz"
    }

    spec = {
      entryPoints = ["websecure"]

      routes = [
        {
          match = "Host(`linkerd.${var.base_domain}`)"
          kind  = "Rule"
          services = [
            { name = "web", port = 8084 }
          ]
          middlewares = [
            { name = "kani-linkerd-middleware" },
            { name = "l5d-header" },
          ]
        }
      ]
    }
  }

  depends_on = [
    kubernetes_manifest.kani_linkerd_middleware,
    kubernetes_manifest.l5d_header_middleware,
  ]
}