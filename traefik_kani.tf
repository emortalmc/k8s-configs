locals {
  prod_middlewares = {
    "argo" = { namespace = "argocd", aud = "d6a87f3e3f7d2a2d54b50a7faa177f4146690992110679decf4ed403b5e80009" },
    "grafana" = { namespace = "monitoring", aud = "d8d23f5bede65e1937c30377d952744306f0e38ba90b844ff437e371fec6f7d3" },
    "linkerd" = { namespace = "linkerd", aud = "c20c081e78a66d7e77888c4a2b1da0eb4382ba275a8e8a4118448510a81dc77a" },
    "traefik" = { namespace = "traefik", aud = "5d66ba76fa7d60bc32c6edb6645f42306cc6070c2991d7b99dea00163cbc5bac" }
  }
  staging_middlewares = {
    "argo" = { namespace = "argocd", aud = "09082b8fda21182a02b5aba5fb60767895716de1a36072b370a92590f9060015" },
    "grafana" = { namespace = "monitoring", aud = "1a56036f8605bf579a72279ed7489926f8afd92485b20a099bafdf1747f6601e" },
    "traefik" = { namespace = "traefik", aud = "651d6b7f07ced98d168bee23e1534bc7c9b50e30b869fb715b4aa929cca6fe49" }
  }
}

resource "kubernetes_deployment" "kani" {
  depends_on = [helm_release.traefik]

  metadata {
    name = "kani"
    namespace = "traefik"
  }

  spec {
    replicas = "1"

    selector {
      match_labels = {
        "app.kubernetes.io/name" = "kani"
      }
    }

    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = "0"
        max_surge = "1"
      }
    }

    template {
      metadata {
        labels = {
          "app.kubernetes.io/name" = "kani"
        }
      }

      spec {
        container {
          name = "kani"
          image = "joshuasing/kani:1.2.8"
          image_pull_policy = "IfNotPresent"

          env {
            name = "CLOUDFLARE_DOMAIN"
            value = "https://emortalmc.cloudflareaccess.com"
          }

          port {
            name = "kani-http"
            container_port = 3000
          }

          liveness_probe {
            http_get {
              path = "/"
              port = "3000"
              scheme = "HTTP"
            }

            initial_delay_seconds = 10
            period_seconds = 5
            timeout_seconds = 5
          }

          readiness_probe {
            http_get {
              path = "/"
              port = "3000"
              scheme = "HTTP"
            }
          }

          resources {
            limits = {
              cpu = "0.10"
              memory = "16Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "kani" {
  depends_on = [helm_release.traefik]

  metadata {
    name = "kani"
    namespace = "traefik"
    labels = {
      "app.kubernetes.io/name" = "kani"
    }
  }

  spec {
    type = "ClusterIP"
    port {
      port = 80
      target_port = "kani-http"
    }
    selector = {
      "app.kubernetes.io/name" = "kani"
    }
  }
}

resource "kubernetes_manifest" "kani-middleware" {
  depends_on = [kubernetes_deployment.kani, kubernetes_service.kani]
  for_each = var.production ? local.prod_middlewares : local.staging_middlewares

  manifest = {
    apiVersion = "traefik.io/v1alpha1"
    kind = "Middleware"

    metadata = {
      name = "kani-${each.key}-middleware"
      namespace = each.value.namespace
    }

    spec = {
      forwardAuth = {
        address = "http://kani.traefik.svc.cluster.local/${each.value.aud}"
        authResponseHeaders = ["X-Auth-User"]
      }
    }
  }
}
