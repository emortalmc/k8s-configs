resource "kubernetes_config_map" "gamemodes" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "gamemodes"
    namespace = "emortalmc"
  }

  // There may be a way to do this better, but dynamic blocks don't seem to work, and I'm not wasting time looking for
  // it for not really that much gain.
  data = {
    "marathon.json"      = file("${path.module}/minecraft/config/marathon.json")
    "lazertag.json"      = file("${path.module}/minecraft/config/lazertag.json")
    "minesweeper.json"   = file("${path.module}/minecraft/config/minesweeper.json")
    "parkourtag.json"    = file("${path.module}/minecraft/config/parkourtag.json")
    "blocksumo.json"     = file("${path.module}/minecraft/config/blocksumo.json")
    "tower-defence.json" = file("${path.module}/minecraft/config/tower-defence.json")
    "battle.json"        = file("${path.module}/minecraft/config/battle.json")
    "lobby.json"         = file("${path.module}/minecraft/config/lobby.json")
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

// Tower Defence Fleet & Autoscaler

// to be removed when TD switches to automated deployment system

/* Commented out for now because we can't install Agones CRDs separately and this will fail in planning
resource "kubernetes_manifest" "tower-defence-fleet" {
  depends_on = [kubernetes_namespace.emortalmc]

  manifest = {
    apiVersion = "agones.dev/v1"
    kind       = "Fleet"

    metadata = {
      name      = "towerdefence"
      namespace = "emortalmc"
    }

    spec = {
      scheduling = "Distributed"

      strategy = {
        type          = "RollingUpdate"
        rollingUpdate = {
          maxSurge       = "25%"
          maxUnavailable = "25%"
        }
      }

      template = {
        spec = {
          ports = [
            {
              name          = "default"
              portPolicy    = "Dynamic"
              containerPort = 25565
              protocol      = "TCP"
            }
          ]

          health = {
            initialDelaySeconds = 5
            periodSeconds       = 15
            failureThreshold    = 2
          }

          template = {
            metadata = {
              labels = {
                "emortal.dev/mc-metrics-enabled" = "true"
              }
            }
            spec = {
              serviceAccountName           = "default-gameserver"
              automountServiceAccountToken = true

              containers = [
                {
                  name    = "towerdefence"
                  image   = "ghcr.io/emortalmc/towerdefence:dev-17"
                  command = ["/bin/sh", "-c", "java -XX:+UseZGC -Xms192M -Xmx192M -jar /app/tower_defence.jar"]

                  resources = {
                    requests = {
                      cpu    = "300m"
                      memory = "384Mi"
                    }
                    limits = {
                      cpu    = "1"
                      memory = "384Mi"
                    }
                  }

                  ports = [
                    {
                      containerPort = 8081
                      name          = "metrics"
                      protocol      = "TCP"
                    }
                  ]

                  env = [
                    {
                      name      = "minestom.velocity-forwarding-secret"
                      valueFrom = {
                        secretKeyRef = {
                          name     = "velocity-forwarding-token"
                          key      = "forwarding.secret"
                          optional = false
                        }
                      }
                    },
                    {
                      name  = "KAFKA_HOST"
                      value = "default-kafka-bootstrap"
                    },
                    {
                      name  = "KAFKA_PORT"
                      value = "9092"
                    },
                    {
                      name      = "NAMESPACE",
                      valueFrom = {
                        fieldRef = {
                          fieldPath = "metadata.namespace"
                        }
                      }
                    },
                    {
                      name  = "FLEET_NAME",
                      value = "towerdefence"
                    }
                  ]
                }
              ]
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_manifest" "tower-defence-fleet-autoscaler" {
  depends_on = [kubernetes_namespace.emortalmc]

  manifest = {
    apiVersion = "autoscaling.agones.dev/v1"
    kind       = "FleetAutoscaler"

    metadata = {
      name      = "towerdefence"
      namespace = "emortalmc"
    }

    spec = {
      fleetName = "towerdefence"
      policy    = {
        type   = "Buffer"
        buffer = {
          bufferSize  = 1
          minReplicas = 2
          maxReplicas = 10
        }
      }
    }
  }
}
*/
