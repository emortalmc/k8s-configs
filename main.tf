terraform {
  backend "s3" {
    region   = "weur"
    endpoint = "https://1326697cfd6760c9915a3c6807d3e812.r2.cloudflarestorage.com"
    bucket   = "terraform"
    key      = "primary.tfstate"

    // Cloudflare R2 only implements some of the S3 API, and implements no other AWS APIs, so STS and EC2 metadata don't work.
    skip_credentials_validation = true
    skip_metadata_api_check     = true

    // Don't validate the region (with AWS region names) because R2 has different region names
    skip_region_validation = true
  }
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.24.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.12.1"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.0.0"
    }
  }
}

variable "production" {
  type = bool
}

locals {
  primary_node = var.production ? "emc-01" : "emc-staging-01"
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

provider "sops" {
}

resource "kubernetes_namespace" "emortalmc" {
  metadata {
    name = "emortalmc"
  }
}
