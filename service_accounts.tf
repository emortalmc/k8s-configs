resource "kubernetes_service_account" "default-gameserver" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "default-gameserver"
    namespace = "emortalmc"
  }
}

resource "kubernetes_service_account" "matchmaker" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "matchmaker"
    namespace = "emortalmc"
  }
}

resource "kubernetes_service_account" "mongodb-database" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "mongodb-database"
    namespace = "emortalmc"
  }
}

resource "kubernetes_service_account" "emortalbot" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "emortalbot"
    namespace = "emortalmc"
  }
}

// Pod reader role & binding

#resource "kubernetes_role" "pod-reader" {
#  depends_on = [kubernetes_namespace.emortalmc]
#
#  metadata {
#    name      = "pod-reader"
#    namespace = "emortalmc"
#  }
#
#  rule {
#    api_groups = [""]
#    resources  = ["pods"]
#    verbs      = ["get", "watch"]
#  }
#}
#
#resource "kubernetes_role_binding" "pod-reader-access" {
#  depends_on = [kubernetes_namespace.emortalmc]
#
#  metadata {
#    name      = "pod-reader-access"
#    namespace = "emortalmc"
#  }
#
#  subject {
#    kind = "ServiceAccount"
#    name = "gameserver"
#  }
#  subject {
#    kind = "ServiceAccount"
#    name = "matchmaker"
#  }
#
#  role_ref {
#    api_group = "rbac.authorization.k8s.io"
#    kind      = "Role"
#    name      = "pod-reader"
#  }
#}

// Agones allocation creator role & binding

resource "kubernetes_role" "allocation-creator" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "allocation-creator"
    namespace = "emortalmc"
  }

  rule {
    api_groups = ["allocation.agones.dev"]
    resources  = ["gameserverallocations"]
    verbs      = ["create"]
  }
}

resource "kubernetes_role_binding" "allocation-creator-access" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "allocation-creator-access"
    namespace = "emortalmc"
  }

  subject {
    kind = "ServiceAccount"
    name = "server-discovery"
    namespace = "emortalmc"
  }
  subject {
    kind = "ServiceAccount"
    name = "matchmaker"
    namespace = "emortalmc"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "allocation-creator"
  }
}

// Additional Agones SDK role binding

resource "kubernetes_role_binding" "additional-agones-sdk-access" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "additional-agones-sdk-access"
    namespace = "emortalmc"
  }

  subject {
    kind = "ServiceAccount"
    name = "default-gameserver"
    namespace = "emortalmc"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "agones-sdk"
  }
}

// Config map reader role & binding

resource "kubernetes_role" "config-map-reader" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "config-map-reader"
    namespace = "emortalmc"
  }

  rule {
    api_groups = [""]
    resources  = ["configmaps"]
    verbs      = ["get", "watch", "list"]
  }
}

resource "kubernetes_role_binding" "config-map-reader-access" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "config-map-reader-access"
    namespace = "emortalmc"
  }

  subject {
    kind = "ServiceAccount"
    name = "default-gameserver"
    namespace = "emortalmc"
  }
  subject {
    kind = "ServiceAccount"
    name = "emortalbot"
    namespace = "emortalmc"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "config-map-reader"
  }
}

// MongoDB database access role & binding

resource "kubernetes_role" "mongodb-reader" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "mongodb-reader"
    namespace = "emortalmc"
  }

  rule {
    api_groups = [""]
    resources  = ["secrets", "pods"]
    verbs      = ["get", "patch"]
  }
}

resource "kubernetes_role_binding" "mongodb-reader-access" {
  depends_on = [kubernetes_namespace.emortalmc]

  metadata {
    name      = "mongodb-reader-access"
    namespace = "emortalmc"
  }

  subject {
    kind = "ServiceAccount"
    name = "mongodb-database"
    namespace = "emortalmc"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "mongodb-reader"
  }
}
