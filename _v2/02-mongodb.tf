locals {
  services = [
    "permission-service",
    "relationship-manager",
    "mc-player-service",
    "player-tracker",
    "party-manager",
    "matchmaker",
    "game-tracker",
    "game-player-data",
  ]
}

resource "kubernetes_namespace" "mongodb" {
  metadata {
    name = "mongodb"
  }
}

# resource "helm_release" "mongodb" {
#   name       = "mongodb-operator"
#   repository = "https://mongodb.github.io/helm-charts"
#   chart      = "community-operator"
#   namespace  = kubernetes_namespace.mongodb.metadata[0].name
#   version    = "0.11.0"
#
#   # We create it manually above
#   create_namespace = false
#
#   values = [
#     yamlencode({
#       operator = {
#         watchNamespace = "emortalmc"
#       }
#     })
#   ]
#
#   wait    = true
#   atomic  = true
#   timeout = 120 # 2 minutes
# }

# Service passwords

resource "random_password" "service_db" {
  for_each = toset(local.services)
  length   = 64
  special  = false
}

resource "kubernetes_secret" "service_db_creds" {
  for_each = toset(local.services)

  metadata {
    name      = "${each.key}-db-creds"
    namespace = "emortalmc"
  }

  data = {
    password          = random_password.service_db[each.key].result
    connection-string = "mongodb://${each.key}:${random_password.service_db[each.key].result}@mongodb-main-svc/${each.key}"
  }

  type = "Opaque"
}

# Master password

resource "random_password" "mongodb_master" {
  length  = 128
  special = false
}

resource "kubernetes_secret" "mongodb_master_password" {
  metadata {
    name      = "mongodb-master-password"
    namespace = "emortalmc"
  }

  data = {
    password = random_password.mongodb_master.result
    username = "mongodb"
  }

  type = "Opaque"
}

# Actual database

resource "kubernetes_manifest" "mongodb_main" {
  manifest = {
    apiVersion = "mongodbcommunity.mongodb.com/v1"
    kind       = "MongoDBCommunity"

    metadata = {
      name      = "mongodb-main"
      namespace = "emortalmc"
    }

    spec = {
      members = 1
      type    = "ReplicaSet"
      version = "8.0.1"

      security = {
        authentication = {
          modes = ["SCRAM"]
        }
      }

      statefulSet = {
        spec = {
          volumeClaimTemplates = [
            {
              metadata = {
                name = "data-volume"
              }
              spec = {
                resources = {
                  requests = {
                    storage = "50Gi"
                  }
                }
              }
            }
          ]
        }
      }

      users = concat(
        [
          {
            name = "mongodb"
            db   = "admin"
            passwordSecretRef = {
              name = kubernetes_secret.mongodb_master_password.metadata[0].name
            }
            roles = [
              { db = "admin", name = "clusterAdmin" },
              { db = "admin", name = "userAdminAnyDatabase" },
              { db = "admin", name = "readWriteAnyDatabase" },
            ]
            scramCredentialsSecretName = "mongodb"
          }
        ],
        [
          for service in local.services : {
            name = service
            db   = service
            passwordSecretRef = {
              name = kubernetes_secret.service_db_creds[service].metadata[0].name
            }
            roles = [
              { db = service, name = "readWrite" }
            ]
            scramCredentialsSecretName = service
          }
        ]
      )

      additionalMongodConfig = {
        "storage.wiredTiger.engineConfig.journalCompressor" = "zlib"
      }
    }
  }

  depends_on = [
    kubernetes_secret.mongodb_master_password,
    kubernetes_secret.service_db_creds,
  ]
}
