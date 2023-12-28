locals {
  // 3600000 = 1 hour, 86400000 = 24 hours
  topics = {
    "party-manager" = 3600000,
    "mc-connections" = 86400000,
    "matchmaker" = 3600000,
    "message-handler" = 86400000,
    "mc-messages" = 86400000,
    "permissions" = 86400000,
    "game-sdk" = 3600000,
    "game-tracker" = 3600000
  }
}

resource "helm_release" "strimzi-kafka" {
  name      = "strimzi-kafka"
  namespace = "strimzi-system"

  repository = "https://strimzi.io/charts/"
  chart      = "strimzi-kafka-operator"

  create_namespace = true
  version = "0.39.0"

  set {
    name  = "watchAnyNamespace"
    value = "true"
  }
  set {
    name  = "replicas"
    value = "2"
  }
}

resource "kubernetes_manifest" "kafka" {
  depends_on = [helm_release.strimzi-kafka, kubernetes_namespace.emortalmc]

  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta2"
    kind       = "Kafka"

    metadata = {
      name      = "default"
      namespace = "emortalmc"
    }

    spec = {
      kafka = {
        version  = "3.6.1"
        replicas = 3

        listeners = [
          {
            name = "plain"
            port = 9092
            type = "internal"
            tls  = false
          }
        ]

        config = {
          "offsets.topic.replication.factor"         = 1
          "transaction.state.log.replication.factor" = 1
          "transaction.state.log.min.isr"            = 1
          "default.replication.factor"               = 1
          "min.insync.replicas"                      = 1
          "inter.broker.protocol.version"            = "3.4"
        }

        storage = {
          type    = "jbod"
          volumes = [
            {
              id          = 0
              type        = "persistent-claim"
              size        = "20Gi"
              deleteClaim = false
            }
          ]
        }
      }

      zookeeper = {
        replicas = 1
        storage  = {
          type        = "persistent-claim"
          size        = "20Gi"
          deleteClaim = false
        }
      }

      entityOperator = {
        topicOperator = {}
        userOperator  = {}
      }
    }
  }
}

resource "kubernetes_manifest" "topic" {
  depends_on = [kubernetes_manifest.kafka]
  for_each = local.topics

  manifest = {
    apiVersion = "kafka.strimzi.io/v1beta1"
    kind = "KafkaTopic"

    metadata = {
      name = each.key
      namespace = "emortalmc"
      labels = {
        "strimzi.io/cluster" = "default"
      }
    }

    spec = {
      topicName = each.key
      partitions = 1
      replicas = 1
      config = {
        "retention.ms" = each.value
      }
    }
  }
}

// Registry operator

#resource "helm_release" "strimzi-registry-operator" {
#  name      = "strimzi-registry-operator"
#  namespace = "strimzi-system"
#
#  repository = "https://lsst-sqre.github.io/charts/"
#  chart      = "strimzi-registry-operator"
#
#  set {
#    name  = "clusterName"
#    value = "default"
#  }
#  set {
#    name  = "clusterNamespace"
#    value = "emortalmc"
#  }
#  set {
#    name  = "operatorNamespace"
#    value = "strimzi-system"
#  }
#}
#
#resource "kubernetes_manifest" "registry-schemas-topic" {
#  manifest = {
#    apiVersion = "kafka.strimzi.io/v1beta2"
#    kind       = "KafkaTopic"
#
#    metadata = {
#      name      = "registry-schemas"
#      namespace = "emortalmc"
#      labels    = {
#        "strimzi.io/cluster" = "events"
#      }
#    }
#
#    spec = {
#      partitions = 1
#      replicas   = 1
#      config     = {
#        "cleanup.policy" = "compact"
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "schema-registry-user" {
#  manifest = {
#    apiVersion = "kafka.strimzi.io/v1beta2"
#    kind       = "KafkaUser"
#
#    metadata = {
#      name      = "confluent-schema-registry"
#      namespace = "emortalmc"
#      labels    = {
#        "strimzi.io/cluster" = "events"
#      }
#    }
#
#    spec = {
#      authentication = {
#        type = "tls"
#      }
#      authorization = {
#        type = "simple"
#        acls = [
#          // Allow all operations on the registry-schemas topic
#          // Read, Write, and DescribeConfigs are known to be required
#          {
#            resource = {
#              type        = "topic"
#              name        = "registry-schemas"
#              patternType = "literal"
#            }
#            operation = "All"
#            type      = "allow"
#          },
#          // Allow all operations on the schema-registry* group
#          {
#            resource = {
#              type        = "group"
#              name        = "schema-registry"
#              patternType = "prefix"
#            }
#            operation = "All"
#            type      = "allow"
#          },
#          // Allow Describe on the __consumer_offsets topic
#          {
#            resource = {
#              type        = "topic"
#              name        = "__consumer_offsets"
#              patternType = "literal"
#            }
#            operation = "Describe"
#            type      = "allow"
#          },
#        ]
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "schema-registry" {
#  manifest = {
#    apiVersion = "roundtable.lsst.codes/v1beta1"
#    kind       = "StrimziSchemaRegistry"
#
#    metadata = {
#      name      = "confluent-schema-registry"
#      namespace = "emortalmc"
#    }
#
#    spec = {
#      strimziVersion = "v1beta2"
#      listener       = "tls"
#    }
#  }
#}
