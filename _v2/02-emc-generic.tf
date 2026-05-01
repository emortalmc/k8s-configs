resource "kubernetes_namespace" "emortalmc" {
  metadata {
    name = "emortalmc"
  }
}

# Velocity forwarding token
resource "random_password" "velocity_forwarding_token" {
  length  = 128
  special = true
  override_special = "~!@#$%^&*_-"
}

resource "kubernetes_secret" "velocity_forwarding_token" {
  metadata {
    name      = "velocity-forwarding-token"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  data = {
    "forwarding.secret" = random_password.velocity_forwarding_token.result
  }

  type = "Opaque"
}

# Edge routing token - TODO don't think this is used any more
resource "random_password" "edge_routing_token" {
  length  = 128
  special = true
  override_special = "~!@#$%^&*_-"
}

resource "kubernetes_secret" "edge_routing_token" {
  metadata {
    name      = "edge-routing-token"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  data = {
    "routing-token" = random_password.edge_routing_token.result
  }

  type = "Opaque"
}