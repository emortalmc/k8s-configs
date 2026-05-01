resource "kubernetes_namespace" "strimzi" {
  metadata {
    name = "strimzi-system"
  }
}

resource "helm_release" "strimzi" {
  name       = "strimzi-kafka"
  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"
  namespace  = kubernetes_namespace.strimzi.metadata[0].name
  version    = "0.51.0" # TODO update to 1.0.0, requires many CRD conversions (have added v1 CRDs to the cluster)

  create_namespace = false

  values = [
    file("files/strimzi-kafka-values.yaml")
  ]

  wait    = true
  atomic  = true
  timeout = 300
}

# Kafka Cluster

resource "kubernetes_manifest" "kafka_cluster" {
  field_manager {
    force_conflicts = true
  }

  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"

    metadata = {
      name      = "default"
      namespace = kubernetes_namespace.emortalmc.metadata[0].name
      annotations = {
        "strimzi.io/node-pools" = "enabled"
        "strimzi.io/kraft"      = "enabled"
      }
    }

    spec = {
      kafka = {
        version  = "4.2.0"
        replicas = 3

        listeners = [
          { name = "plain", port = 9092, type = "internal", tls = false },
          { name = "tls", port = 9093, type = "internal", tls = true },
        ]

        config = {
          "offsets.topic.replication.factor"         = 1
          "transaction.state.log.replication.factor" = 1
          "transaction.state.log.min.isr"            = 1
          "default.replication.factor"               = 1
          "min.insync.replicas"                      = 1
        }

        storage = {
          type = "jbod"
          volumes = [
            { id = 0, type = "persistent-claim", size = "20Gi", deleteClaim = false }
          ]
        }
      }

      entityOperator = {
        topicOperator = {}
        userOperator  = {}
      }
    }
  }

  depends_on = [helm_release.strimzi]
}

resource "kubernetes_manifest" "kafka_nodepool_brokers" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaNodePool"

    metadata = {
      name      = "kafka"
      namespace = kubernetes_namespace.emortalmc.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "default"
      }
    }

    spec = {
      replicas = 3
      roles    = ["broker"]
      storage = {
        type = "jbod"
        volumes = [
          { id = 0, type = "persistent-claim", size = "20Gi", deleteClaim = false }
        ]
      }
    }
  }
}

resource "kubernetes_manifest" "kafka_nodepool_controllers" {
  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaNodePool"

    metadata = {
      name      = "controller"
      namespace = kubernetes_namespace.emortalmc.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "default"
      }
    }

    spec = {
      replicas = 1
      roles    = ["controller"]
      storage = {
        type        = "persistent-claim"
        size        = "10Gi"
        deleteClaim = false
      }
    }
  }
}

# Kafka Topics

locals {
  kafka_topics = {
    "party-manager"   = { retention_ms = 3600000 }
    "matchmaker"      = { retention_ms = 3600000 }
    "game-sdk"        = { retention_ms = 3600000 }
    "mc-connections"  = { retention_ms = 86400000 }
    "message-handler" = { retention_ms = 86400000 }
    "mc-messages"     = { retention_ms = 86400000 }
    "permissions"     = { retention_ms = 86400000 }
  }
}

resource "kubernetes_manifest" "kafka_topic" {
  for_each = local.kafka_topics

  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "KafkaTopic"

    metadata = {
      name      = each.key
      namespace = kubernetes_namespace.emortalmc.metadata[0].name
      labels = {
        "strimzi.io/cluster" = "default"
      }
    }

    spec = {
      topicName  = each.key
      partitions = try(each.value["partitions"], 1)
      replicas   = try(each.value["replicas"], 1)
      config = {
        "retention.ms" = each.value["retention_ms"]
      }
    }
  }

  depends_on = [kubernetes_manifest.kafka_cluster]
}
