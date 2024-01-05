// Global monitoring namespace

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

// Prometheus stack - Prometheus, Grafana, etc.

resource "kubernetes_config_map" "grafana-cloudflare-auth" {
  depends_on = [kubernetes_namespace.monitoring]

  metadata {
    name = "grafana-cloudflare-auth"
    namespace = "monitoring"
  }

  data = {
    GF_AUTH_PROXY_ENABLED = "true"
    GF_AUTH_PROXY_HEADER_NAME = "X-Auth-User"
    GF_AUTH_PROXY_AUTO_SIGN_UP = "true"
    GF_USERS_AUTO_ASSIGN_ORG_ROLE = "Admin"
  }
}

resource "helm_release" "prom-stack" {
  depends_on = [kubernetes_namespace.monitoring, kubernetes_config_map.grafana-cloudflare-auth]

  name      = "prom-stack"
  namespace = "monitoring"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "55.5.2"

  values = [file("${path.module}/values/prom-stack.yaml")]
}

// Monitors

resource "kubernetes_manifest" "agones-allocator-monitor" {
  depends_on = [helm_release.agones]

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata   = {
      name      = "agones-allocator-monitor"
      namespace = "agones-system"
      labels    = {
        "multicluster.agones.dev/role" = "allocator"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "multicluster.agones.dev/role" = "allocator"
        }
      }
      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "10s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "agones-controller-monitor" {
  depends_on = [helm_release.agones]

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata   = {
      name      = "agones-controller-monitor"
      namespace = "agones-system"
      labels    = {
        "multicluster.agones.dev/role" = "controller"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "multicluster.agones.dev/role" = "controller"
        }
      }
      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "10s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "agones-extensions-monitor" {
  depends_on = [helm_release.agones]

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "ServiceMonitor"
    metadata   = {
      name      = "agones-extensions-monitor"
      namespace = "agones-system"
      labels    = {
        "multicluster.agones.dev/role" = "extensions"
      }
    }
    spec = {
      selector = {
        matchLabels = {
          "multicluster.agones.dev/role" = "extensions"
        }
      }
      endpoints = [
        {
          port     = "http"
          path     = "/metrics"
          interval = "10s"
        }
      ]
    }
  }
}

resource "kubernetes_manifest" "mc-metrics-monitor" {
  depends_on = [kubernetes_namespace.emortalmc]

  manifest = {
    apiVersion = "monitoring.coreos.com/v1"
    kind       = "PodMonitor"

    metadata = {
      name      = "mc-metrics-monitor"
      namespace = "emortalmc"
    }

    spec = {
      selector = {
        matchLabels = {
          "emortal.dev/mc-metrics-enabled" = "true"
        }
      }
      podMetricsEndpoints = [
        {
          port = "metrics"
          path = "/metrics"
        }
      ]
    }
  }
}

// Loki

resource "helm_release" "loki" {
  depends_on = [kubernetes_namespace.monitoring]

  name      = "loki"
  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "loki"

  set {
    name  = "loki.commonConfig.replication_factor"
    value = "1"
  }

  set {
    name  = "loki.storage.type"
    value = "filesystem"
  }

  set {
    name  = "loki.auth_enabled"
    value = "false"
  }

  set {
    name  = "loki.monitoring.selfMonitoring.grafanaAgent.installOperator"
    value = "false"
  }

  set {
    name  = "singleBinary.replicas"
    value = "1"
  }
  set {
    name  = "singleBinary.persistence.size"
    value = "20Gi"
  }
}

resource "kubernetes_config_map" "loki-grafana-datasource" {
  depends_on = [kubernetes_namespace.monitoring]

  metadata {
    name      = "loki-grafana-datasource"
    namespace = "monitoring"
    labels    = {
      grafana_datasource = "1"
    }
  }

  data = {
    "datasource.yaml" = <<EOF
apiVersion: 1
datasources:
  - name: Loki
    type: loki
    access: proxy
    url: http://loki:3100
    version: 1
    editable: false
    EOF
  }
}

// Promtail

resource "helm_release" "promtail" {
  depends_on = [kubernetes_namespace.monitoring]

  name      = "promtail"
  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "promtail"

  values = [file("${path.module}/values/promtail.yaml")]
}

// Pyroscope

resource "helm_release" "pyroscope" {
  depends_on = [kubernetes_namespace.monitoring]

  name      = "pyroscope"
  namespace = "monitoring"

  repository = "https://grafana.github.io/helm-charts"
  chart      = "pyroscope"

  values = [file("${path.module}/values/pyroscope.yaml")]
}

resource "kubernetes_config_map" "pyroscope-grafana-datasource" {
  depends_on = [kubernetes_namespace.monitoring]

  metadata {
    name      = "pyroscope-grafana-datasource"
    namespace = "monitoring"
    labels    = {
      grafana_datasource = "1"
    }
  }

  data = {
    "datasource.yaml" = <<EOF
apiVersion: 1
datasources:
  - name: "Pyroscope"
    type: grafana-pyroscope-datasource
    access: proxy
    url: http://pyroscope-query-frontend.monitoring.svc.cluster.local:4040
    version: 1
    EOF
  }
}

resource "kubernetes_config_map" "pyroscope-emortalmc" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "pyroscope"
    namespace = "emortalmc"
  }

  data = {
    address = "http://pyroscope-distributor.monitoring.svc.cluster.local:4040"
  }
}

// Grafana dashboards

resource "kubernetes_manifest" "grafana-dashboard-agones" {
  depends_on = [kubernetes_namespace.monitoring]
  for_each = fileset(path.module, "grafana/dashboard/agones/*.yaml")

  manifest = yamldecode(file(each.value))
}

resource "kubernetes_manifest" "grafana-dashboard-loki" {
  depends_on = [kubernetes_namespace.monitoring]
  for_each = fileset(path.module, "grafana/dashboard/loki/*.yaml")

  manifest = yamldecode(file(each.value))
}

resource "kubernetes_manifest" "grafana-dashboard-minecraft" {
  depends_on = [kubernetes_namespace.monitoring]
  for_each = fileset(path.module, "grafana/dashboard/minecraft/*.yaml")

  manifest = yamldecode(file(each.value))
}
