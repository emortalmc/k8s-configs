resource "helm_release" "mongodb-operator" {
  name      = "mongodb-operator"
  namespace = "mongodb"

  repository = "https://mongodb.github.io/helm-charts"
  chart      = "community-operator"

  version = "0.8.0"
  create_namespace = true

  set {
    name  = "operator.watchNamespace"
    value = "emortalmc"
  }
  set {
    name  = "community-operator-crds.enabled"
    value = "false"
  }
}

locals {
  mongo_apps = toset(["permission-service", "relationship-manager", "mc-player-service", "player-tracker", "party-manager", "matchmaker"])
}

// MongoDB credentials

resource "random_string" "mongodb-password" {
  for_each = local.mongo_apps

  length = 16
  special = false
}

resource "kubernetes_secret" "mongodb-credentials-secret" {
  depends_on = [kubernetes_namespace.emortalmc]
  for_each = local.mongo_apps

  metadata {
    name = "${each.key}-db-creds"
    namespace = "emortalmc"
  }

  type = "Opaque"
  data = {
    password = random_string.mongodb-password[each.key].result
    connection-string = "mongodb://${each.key}:${random_string.mongodb-password[each.key].result}@mongodb-main-svc/${each.key}"
  }
}

// MongoDB databases

resource "kubernetes_manifest" "mongodb-main" {
  depends_on = [helm_release.mongodb-operator, kubernetes_namespace.emortalmc]

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
      version = "6.0.6"

      security = {
        authentication = {
          modes = ["SCRAM"]
        }
      }

      users = [
#        {
#          name              = "mongodb"
#          db                = "admin"
#          passwordSecretRef = {
#            name = "mongodb-master-password"
#          }
#          roles = [
#            {
#              db   = "admin"
#              name = "clusterAdmin"
#            },
#            {
#              db   = "admin"
#              name = "userAdminAnyDatabase"
#            },
#            {
#              db   = "admin"
#              name = "readWriteAnyDatabase"
#            }
#          ]
#          scramCredentialsSecretName = "mongodb"
#        },
        {
          name              = "permission-service"
          db                = "permission-service"
          passwordSecretRef = {
            name = "permission-service-db-creds"
          }
          roles = [
            {
              db   = "permission-service"
              name = "readWrite"
            }
          ]
          scramCredentialsSecretName = "permission-service"
        },
        {
          name              = "relationship-manager"
          db                = "relationship-manager"
          passwordSecretRef = {
            name = "relationship-manager-db-creds"
          }
          roles = [
            {
              db   = "relationship-manager"
              name = "readWrite"
            }
          ]
          scramCredentialsSecretName = "relationship-manager"
        },
        {
          name              = "mc-player-service"
          db                = "mc-player-service"
          passwordSecretRef = {
            name = "mc-player-service-db-creds"
          }
          roles = [
            {
              db   = "mc-player-service"
              name = "readWrite"
            }
          ]
          scramCredentialsSecretName = "mc-player-service"
        },
        {
          name              = "player-tracker"
          db                = "player-tracker"
          passwordSecretRef = {
            name = "player-tracker-db-creds"
          }
          roles = [
            {
              db   = "player-tracker"
              name = "readWrite"
            }
          ]
          scramCredentialsSecretName = "player-tracker"
        },
        {
          name              = "party-manager"
          db                = "party-manager"
          passwordSecretRef = {
            name = "party-manager-db-creds"
          }
          roles = [
            {
              db   = "party-manager"
              name = "readWrite"
            }
          ]
          scramCredentialsSecretName = "party-manager"
        },
        {
          name              = "matchmaker"
          db                = "matchmaker"
          passwordSecretRef = {
            name = "matchmaker-db-creds"
          }
          roles = [
            {
              db   = "matchmaker"
              name = "readWrite"
            }
          ]
          scramCredentialsSecretName = "matchmaker"
        },
      ]

      additionalMongodConfig = {
        "storage.wiredTiger.engineConfig.journalCompressor" = "zlib"
      }
    }
  }
}
