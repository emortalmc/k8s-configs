resource "helm_release" "agones" {
  depends_on = [kubernetes_namespace.emortalmc]

  name      = "agones"
  namespace = "agones-system"

  repository = "https://agones.dev/chart/stable"
  chart      = "agones"

  create_namespace = true
  version          = "1.34.0"

  set {
    name  = "gameservers.namespaces[0]"
    value = "emortalmc"
  }

  set {
    // We don't need or use the external allocator service at the moment, and the load balancer for it stays in pending
    // forever, so there's no point in enabling it.
    name  = "agones.allocator.install"
    value = "false"
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

  set {
    name  = "agones.image.sdk.cpuRequest"
    value = "20m"
  }
  set {
    name  = "agones.image.sdk.cpuLimit"
    value = "30m"
  }
  set {
    name  = "agones.image.sdk.memoryRequest"
    value = "16Mi"
  }
  set {
    name  = "agones.image.sdk.memoryLimit"
    value = "32Mi"
  }
}
