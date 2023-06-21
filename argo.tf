locals {
  // Mapping of app name to repo name
  argo_apps = {
    "battle"               = "battle",
    "blocksumo"            = "blocksumo",
    "lazertag"             = "lazertag",
    "lobby"                = "lobby",
    "matchmaker"           = "kurushimi",
    "mc-player-service"    = "mc-player-service",
    "message-handler"      = "message-handler",
    "minesweeper"          = "minesweeper",
    "parkourtag"           = "parkourtag",
    "party-manager"        = "party-manager",
    "permission-service"   = "permission-service-go",
    "player-tracker"       = "player-tracker",
    "relationship-manager" = "relationship-manager-service",
    "velocity"             = "velocity-core"
  }
}

resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  create_namespace = true
  version          = "5.36.5"

  set {
    name  = "crds.install"
    value = "false"
  }
  set {
    name  = "crds.keep"
    value = "true"
  }

  set {
    name  = "global.revisionHistoryLimit"
    value = "10"
  }
  set {
    name  = "global.logging.format"
    value = "json"
  }

  set {
    name  = "configs.cm.admin\\.enabled"
    value = "false"
  }
  set {
    name  = "configs.cm.users\\.anonymous\\.enabled"
    value = "true"
  }
  set {
    name  = "configs.params.server\\.insecure"
    value = "true"
  }
  set {
    name  = "configs.rbac.policy\\.default"
    value = "role:admin"
  }
}

resource "kubernetes_manifest" "emortalmc-project" {
  depends_on = [helm_release.argocd]

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind = "AppProject"

    metadata = {
      name = "emortalmc"
      namespace = "argocd"
    }

    spec = {
      description = "All the games and services that make up EmortalMC"

      sourceRepos = ["git@github.com:emortalmc/*"]
      sourceNamespaces = ["emortalmc"]

      destinations = [
        {
          namespace = "emortalmc"
          server = "https://kubernetes.default.svc"
        }
      ]
    }
  }
}

resource "kubernetes_secret" "private-credentials" {
  depends_on = [helm_release.argocd]

  metadata {
    name = "private-credentials"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repo-creds"
    }
  }

  data = {
    type = "git"
    url = "git@github.com:emortalmc"
    sshPrivateKey = data.vault_kv_secret_v2.argo.data["access-key"]
  }
}

resource "kubernetes_secret" "repo" {
  depends_on = [helm_release.argocd]
  for_each = local.argo_apps

  metadata {
    name = "${each.key}-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url = "git@github.com:emortalmc/${each.value}.git"
  }
}

resource "kubernetes_manifest" "app" {
  depends_on = [helm_release.argocd, kubernetes_namespace.emortalmc]
  for_each = local.argo_apps

  manifest = yamldecode(templatefile("${path.module}/templates/argocd-app-spec.tftpl", {
    name = each.key,
    repo-name = each.value,
    production = var.production
  }))
}

