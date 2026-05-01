resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = "7.6.11"

  create_namespace = false

  values = [
    file("files/argocd-values.yaml")
  ]

  wait    = true
  atomic  = true
  timeout = 300
}

# deployment repo SSH key secret

resource "kubernetes_secret" "argocd_deployments_repo" {
  metadata {
    name      = "argocd-deployments-repo"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type          = "git"
    url           = "git@github.com:emortalmc/argocd-deployments.git"
    sshPrivateKey = data.sops_file.secrets.data["argocd_deployments_ssh_key"]
  }

  type = "Opaque"
}

# AppProject (EmortalMC)
resource "kubernetes_manifest" "argocd_project_emortalmc" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"

    metadata = {
      name      = "emortalmc"
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }

    spec = {
      description      = "All the games and services that make up EmortalMC"
      sourceNamespaces = ["emortalmc"]
      sourceRepos      = ["git@github.com:emortalmc/argocd-deployments.git"]
      destinations = [
        {
          name      = "Kubernetes"
          namespace = "emortalmc"
          server    = "https://kubernetes.default.svc"
        }
      ]
    }
  }

  depends_on = [helm_release.argocd]
}

# ArgoCD Applications

locals {
  argocd_apps = merge(
    { for s in var.servers : s => { path = "server", values_path = "values/${s}.yaml" } },
    { for name, cfg in var.services : name => { path = "service", values_path = "values/${name}.yaml" } },
    var.extras,
  )
}

resource "kubernetes_manifest" "argocd_app" {
  for_each = local.argocd_apps

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"

    metadata = {
      name      = each.key
      namespace = kubernetes_namespace.argocd.metadata[0].name
    }

    spec = {
      project = "emortalmc"
      source = {
        repoURL = "git@github.com:emortalmc/argocd-deployments.git"
        path    = each.value["path"]
        helm = {
          valueFiles = [each.value["values_path"]]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "emortalmc"
      }
    }
  }

  depends_on = [kubernetes_manifest.argocd_project_emortalmc]
}
