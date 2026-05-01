terraform {
  required_version = ">= 1.9"

  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.36.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    sops = {
      source  = "carlpett/sops"
      version = "1.2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.7.2"
    }
  }

  backend "s3" {
    bucket                      = "emortalmc-tf-state"
    key                         = "prod-v2.tfstate"
    region                      = "auto"
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    skip_s3_checksum            = true
    use_path_style              = true
    endpoints                   = { s3 = "https://73aeee3e82158c41bd3cc353cfcfb0a4.r2.cloudflarestorage.com" }
  }
}

provider "kubernetes" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}

provider "helm" {
  kubernetes {
    config_path    = var.kubeconfig_path
    config_context = var.kubeconfig_context
  }
}

provider "kubectl" {
  config_path    = var.kubeconfig_path
  config_context = var.kubeconfig_context
}
