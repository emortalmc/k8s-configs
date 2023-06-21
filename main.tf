terraform {
  backend "s3" {
    region = "weur" // We store our data
    endpoint = "https://1326697cfd6760c9915a3c6807d3e812.r2.cloudflarestorage.com"
    bucket = "terraform-state"
    key = "primary.tfstate"

    // Cloudflare R2 only implements some of the S3 API, and implements no other AWS APIs, so STS and EC2 metadata don't work.
    skip_credentials_validation = true
    skip_metadata_api_check = true

    // Don't validate the region (with AWS region names) because R2 has different region names
    skip_region_validation = true
  }
}

variable "production" {
  type = bool
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

provider "helm" {
  kubernetes {
    config_path = "~/.kube/config"
  }
}

provider "random" {
}

resource "kubernetes_namespace" "emortalmc" {
  metadata {
    name = "emortalmc"
  }
}

resource "helm_release" "redis" {
  depends_on = [kubernetes_namespace.emortalmc]

  name      = "redis"
  namespace = "emortalmc"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "redis"

  set {
    name  = "auth.enabled"
    value = "false"
  }
  set {
    name  = "auth.sentinel"
    value = "false"
  }
  set {
    name  = "replica.replicaCount"
    value = "2"
  }
  set {
    name  = "nameOverride"
    value = "redis"
  }
}
