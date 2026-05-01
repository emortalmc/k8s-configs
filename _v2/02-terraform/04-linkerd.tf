# LinkerD cert prerequisites

resource "tls_private_key" "linkerd_trust_anchor" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_self_signed_cert" "linkerd_trust_anchor" {
  private_key_pem = tls_private_key.linkerd_trust_anchor.private_key_pem

  subject {
    common_name = "root.linkerd.cluster.local"
  }

  validity_period_hours = 87600 # 10 years, I don't wanna regen this
  is_ca_certificate     = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

# Issuer cert, signed by the trust anchor

resource "tls_private_key" "linkerd_issuer" {
  algorithm   = "ECDSA"
  ecdsa_curve = "P256"
}

resource "tls_cert_request" "linkerd_issuer" {
  private_key_pem = tls_private_key.linkerd_issuer.private_key_pem

  subject {
    common_name = "identity.linkerd.cluster.local"
  }
}

resource "tls_locally_signed_cert" "linkerd_issuer" {
  cert_request_pem   = tls_cert_request.linkerd_issuer.cert_request_pem
  ca_private_key_pem = tls_private_key.linkerd_trust_anchor.private_key_pem
  ca_cert_pem        = tls_self_signed_cert.linkerd_trust_anchor.cert_pem

  validity_period_hours = 8760 # 1 year

  is_ca_certificate = true

  allowed_uses = [
    "cert_signing",
    "crl_signing",
  ]
}

# LinkerD itself

resource "kubernetes_namespace" "linkerd" {
  metadata {
    name = "linkerd"
    labels = {
      "linkerd.io/is-control-plane"          = "true"
      "config.linkerd.io/admission-webhooks" = "disabled"
      "linkerd.io/control-plane-ns"          = "linkerd"
    }
    annotations = {
      "linkerd.io/inject" = "disabled"
    }
  }
}

# Separate LinkerD CRDs chart

resource "helm_release" "linkerd_crds" {
  name       = "linkerd-crds"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-crds"
  namespace  = kubernetes_namespace.linkerd.metadata[0].name
  version    = "2026.4.4"

  create_namespace = false

  wait = true
}

# Control plane chart
resource "helm_release" "linkerd_control_plane" {
  name       = "linkerd-control-plane"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-control-plane"
  namespace  = kubernetes_namespace.linkerd.metadata[0].name
  version    = "2026.4.4"

  create_namespace = false

  set {
    name  = "identityTrustAnchorsPEM"
    value = tls_self_signed_cert.linkerd_trust_anchor.cert_pem
  }

  set {
    name  = "identity.issuer.tls.crtPEM"
    value = tls_locally_signed_cert.linkerd_issuer.cert_pem
  }

  set {
    name  = "identity.issuer.tls.keyPEM"
    value = tls_private_key.linkerd_issuer.private_key_pem
  }

  wait    = true
  atomic  = true
  timeout = 300

  depends_on = [helm_release.linkerd_crds]
}

# LinkerD Viz (web UI)
resource "kubernetes_namespace" "linkerd_viz" {
  metadata {
    name = "linkerd-viz"
    labels = {
      "linkerd.io/extension" = "viz"
    }
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
  }
}

resource "helm_release" "linkerd_viz" {
  name       = "linkerd-viz"
  repository = "https://helm.linkerd.io/edge"
  chart      = "linkerd-viz"
  namespace  = kubernetes_namespace.linkerd_viz.metadata[0].name
  version    = "2026.4.4"

  create_namespace = false

  wait    = true
  atomic  = true
  timeout = 300

  depends_on = [helm_release.linkerd_control_plane]
}
