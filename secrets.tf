provider "vault" {
  address = "https://emc-01.tail27704.ts.net:8200"
  skip_tls_verify = true // Doesn't matter as we're accessing it over the VPN
}

// Secrets from Vault

data "vault_kv_secret_v2" "cloudflare" {
  mount = "terraform"
  name  = "cloudflare"
}

data "vault_kv_secret_v2" "argo" {
  mount = "terraform"
  name  = "argo"
}

// Traefik Cloudflare API secrets

resource "kubernetes_secret" "cloudflare-api" {
  metadata {
    name      = "cloudflare-api"
    namespace = "kube-system"
  }

  data = {
    CLOUDFLARE_EMAIL         = data.vault_kv_secret_v2.cloudflare.data["email"]
    CLOUDFLARE_DNS_API_TOKEN = data.vault_kv_secret_v2.cloudflare.data["api-token"]
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
