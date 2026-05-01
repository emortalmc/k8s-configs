# Service Accounts

resource "kubernetes_service_account" "default_gameserver" {
  metadata {
    name      = "default-gameserver"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

resource "kubernetes_service_account" "matchmaker" {
  metadata {
    name      = "matchmaker"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

resource "kubernetes_service_account" "mongodb_database" {
  metadata {
    name      = "mongodb-database"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

resource "kubernetes_service_account" "emortalbot" {
  metadata {
    name      = "emortalbot"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

# Roles

resource "kubernetes_role" "pod_reader" {
  metadata {
    name      = "pod-reader"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["pods"]
    verbs      = ["get", "watch"]
  }
}

resource "kubernetes_role" "allocation_creator" {
  metadata {
    name      = "allocation-creator"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  rule {
    api_groups = ["allocation.agones.dev"]
    resources  = ["gameserverallocations"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role" "config_map_reader" {
  metadata {
    name      = "config-map-reader"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_role" "mongodb_reader" {
  metadata {
    name      = "mongodb-reader"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  rule {
    api_groups = [""]
    resources  = ["secrets", "pods"]
    verbs      = ["get", "patch"]
  }
}

# Role Bindings

resource "kubernetes_role_binding" "pod_reader_access" {
  metadata {
    name      = "pod-reader-access"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.pod_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "gameserver"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.matchmaker.metadata[0].name
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

resource "kubernetes_role_binding" "allocation_creator_access" {
  metadata {
    name      = "allocation-creator-access"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.allocation_creator.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = "server-discovery"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.matchmaker.metadata[0].name
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

resource "kubernetes_role_binding" "config_map_reader_access" {
  metadata {
    name      = "config-map-reader-access"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.config_map_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.default_gameserver.metadata[0].name
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.emortalbot.metadata[0].name
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

resource "kubernetes_role_binding" "mongodb_reader_access" {
  metadata {
    name      = "mongodb-reader-access"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.mongodb_reader.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.mongodb_database.metadata[0].name
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}

resource "kubernetes_role_binding" "additional_agones_sdk_access" {
  metadata {
    name      = "additional-agones-sdk-access"
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "agones-sdk"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.default_gameserver.metadata[0].name
    namespace = kubernetes_namespace.emortalmc.metadata[0].name
  }
}