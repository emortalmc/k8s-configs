resource "helm_release" "agones" {
  depends_on = [kubernetes_namespace.emortalmc]

  name      = "agones"
  namespace = "agones-system"

  repository = "https://agones.dev/chart/stable"
  chart      = "agones"

  create_namespace = true
  version          = "1.32.0"

  set {
    name  = "gameservers.namespaces[0]"
    value = "emortalmc"
  }

  set {
    name  = "agones.allocator.service.http.enabled"
    value = "false"
  }

  set {
    name  = "agones.ping.install"
    // If we enable this in the future we'll need to change the service type (that's a helm chart option)
    value = "false"
  }

  set {
    // We don't need or use the external allocator service at the moment, and the load balancer for it stays in pending
    // forever, so there's no point in enabling it.
    name  = "agones.allocator.install"
    value = "false"
  }

  set {
    name  = "agones.metrics.prometheusEnabled"
    value = "true"
  }
  set {
    name  = "agones.metrics.prometheusServiceDiscovery"
    value = "true"
  }
  set {
    name  = "agones.metrics.serviceMonitor.interval"
    value = "10s"
  }

  set {
    name  = "agones.featureGates"
    value = "PlayerTracking=true&PlayerAllocationFilter=true&FleetAllocationOverflow=true"
  }

  set {
    name  = "agones.controller.allocationBatchWaitTime"
    value = "300ms"
  }
}

// Service monitors

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
