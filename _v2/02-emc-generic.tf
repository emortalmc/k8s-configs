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
