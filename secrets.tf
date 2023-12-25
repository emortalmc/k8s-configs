provider "sops" {}

// Secrets from SOPS

data "sops_file" "secrets" {
  source_file = "secrets.enc.yaml"
}

// Traefik Cloudflare API secrets

resource "kubernetes_secret" "cloudflare-api" {
  metadata {
    name      = "cloudflare-api"
    namespace = "kube-system"
  }

  data = {
    CLOUDFLARE_EMAIL         = data.sops_file.secrets.data["cloudflare.email"]
    CLOUDFLARE_DNS_API_TOKEN = data.sops_file.secrets.data["cloudflare.api-token"]
  }
}

// Velocity forwarding secret

resource "random_string" "velocity-forwarding-token" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "velocity-forwarding-token" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "velocity-forwarding-token"
    namespace = "emortalmc"
  }

  data = {
    "forwarding.secret" = random_string.velocity-forwarding-token.result
  }
}