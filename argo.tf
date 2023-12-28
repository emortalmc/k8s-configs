locals {
  // Mapping of app name to repo name
  argo_apps = {
    "battle" = { path = "server", values_path = null },
    "blocksumo" = { path = "server", values_path = null },
    "lazertag" = { path = "server", values_path = null },
    "lobby" = { path = "server", values_path = null },
    "minesweeper" = { path = "server", values_path = null },
    "parkourtag" = { path = "server", values_path = null },
    "velocity-core" = { path = "velocity", values_path = "values.yaml" },
    "matchmaker" = { path = "service", values_path = null },
    "mc-player-service" = { path = "service", values_path = null },
    "message-handler" = { path = "service", values_path = null },
    "party-manager" = { path = "service", values_path = null },
    "permission-service" = { path = "service", values_path = null },
    "relationship-manager" = { path = "service", values_path = null }
  }
}

resource "helm_release" "argocd" {
  name      = "argocd"
  namespace = "argocd"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  create_namespace = true
  version          = "5.36.5"

  values = [file("${path.module}/values/argo.yaml")]
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

      sourceNamespaces = ["emortalmc"]
      sourceRepos = ["git@github.com:emortalmc/argocd-deployments.git"]

      destinations = [
        {
          name = "Kubernetes"
          namespace = "emortalmc"
          server = "https://kubernetes.default.svc"
        }
      ]
    }
  }
}

resource "kubernetes_secret" "argocd-deployments-repo" {
  depends_on = [helm_release.argocd]

  metadata {
    name = "argocd-deployments-repo"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type = "git"
    url = "git@github.com:emortalmc/argocd-deployments.git"
    sshPrivateKey = data.sops_file.secrets.data["argocd-access-key"]
  }
}

resource "kubernetes_manifest" "app" {
  depends_on = [helm_release.argocd, kubernetes_namespace.emortalmc]
  for_each = local.argo_apps

  manifest = yamldecode(templatefile("${path.module}/templates/argocd-app-spec.tftpl", {
    name = each.key,
    path = each.value.path,
    values_path = each.value.values_path != null ? each.value.values_path : "values/${each.key}.yaml",
    production = var.production
  }))
}

