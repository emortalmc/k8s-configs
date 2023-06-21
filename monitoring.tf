// Global monitoring namespace

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

// Prometheus stack - Prometheus, Grafana, etc.

resource "kubernetes_config_map" "grafana-anonymous-auth" {
  depends_on = [kubernetes_namespace.monitoring]

  metadata {
    name      = "grafana-anonymous-auth"
    namespace = "monitoring"
  }

  data = {
    GF_AUTH_ANONYMOUS_ENABLED     = "true"
    GF_USERS_AUTO_ASSIGN_ORG_ROLE = "Admin"
  }
}

resource "helm_release" "prom-stack" {
  depends_on = [kubernetes_namespace.monitoring, kubernetes_config_map.grafana-anonymous-auth]

  name      = "prom-stack"
  namespace = "monitoring"

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "46.6.0"

  // We use values rather than set here because of the empty maps in the `prometheus` section
  values = [
    <<EOF
grafana:
  persistence:
    enabled: true

  envFromConfigMaps:
    - name: grafana-anonymous-auth
      optional: false

  plugins:
    - pyroscope-datasource
    - pyroscope-panel

prometheus-node-exporter:
  prometheusSpec:
    scrapeInterval: 10s

# Allow PodMonitors and ServiceMonitors to be created in any namespace.
prometheus:
  prometheusSpec:
    podMonitorNamespaceSelector:
      matchLabels: {}
    podMonitorSelectorNilUsesHelmValues: false
    serviceMonitorNamespaceSelector:
      matchLabels: {}
    serviceMonitorSelectorNilUsesHelmValues: false
    EOF
  ]
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

  // We use values rather than set here because of the empty maps in the `config` section
  values = [
    <<EOF
loki:
  serviceName: loki

config:
  snippets:
    pipelineStages:
      - cri: {}
      - multiline:
          firstline: '^\[\d{2}:\d{2}:?\d{2}\s\S+\]:? \[.*]'
          max_wait_time: 3s
          max_lines: 128
      - pack: {}
    EOF
  ]
}

// Pyroscope

resource "helm_release" "pyroscope" {
  name      = "pyroscope"
  namespace = "pyroscope"

  repository = "https://pyroscope-io.github.io/helm-chart"
  chart      = "pyroscope"

  create_namespace = true

  set {
    name  = "persistence.enabled"
    value = "true"
  }
  set {
    name  = "persistence.size"
    value = "25Gi"
  }
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
  - name: Pyroscope
    type: pyroscope-datasource
    access: proxy
    jsonData:
      path: http://pyroscope.pyroscope.svc:4040
    version: 1
    editable: false
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
    address = "http://pyroscope.pyroscope.svc:4040"
  }
}

// Grafana dashboards

resource "kubernetes_manifest" "grafana-dashboard-agones" {
  depends_on = [kubernetes_namespace.monitoring]
  for_each = toset([
    "allocations",
    "allocator-usage",
    "apiserver-requests",
    "autoscalers",
    "controller-usage",
    "gameservers",
    "goclient-caches",
    "goclient-requests",
    "goclient-workqueues",
    "status"
  ])

  manifest = yamldecode(file("${path.module}/grafana/dashboard/agones/${each.key}.yaml"))
}

resource "kubernetes_manifest" "grafana-dashboard-loki" {
  depends_on = [kubernetes_namespace.monitoring]
  for_each = toset(["canary"])

  manifest = yamldecode(file("${path.module}/grafana/dashboard/loki/${each.key}.yaml"))
}

resource "kubernetes_manifest" "grafana-dashboard-minecraft" {
  depends_on = [kubernetes_namespace.monitoring]
  for_each = toset(["server"])

  manifest = yamldecode(file("${path.module}/grafana/dashboard/minecraft/${each.key}.yaml"))
}
