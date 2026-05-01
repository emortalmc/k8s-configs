## Core Variables

variable "kubeconfig_path" {
  type = string
}

variable "kubeconfig_context" {
  type = string
}

# End-applications (Services/Servers/Extras)

variable "services" {
  description = "Services with optional MongoDB database"
  type = map(object({
    has_db = bool
  }))
  default = {
    "permission-service"   = { has_db = true }
    "relationship-manager" = { has_db = true }
    "mc-player-service"    = { has_db = true }
    "party-manager"        = { has_db = true }
    "matchmaker"           = { has_db = true }
    "game-tracker"         = { has_db = true }
    "game-player-data"     = { has_db = true }
    "message-handler"      = { has_db = false }
  }
}

variable "servers" {
  description = "Game servers that need an ArgoCD app"
  type        = list(string)
  default = [
    "battle",
    "blocksumo",
    "lazertag",
    "holeymoley",
    "lobby",
    "marathon",
    "minesweeper",
    "parkourtag",
    "tower-defence",
  ]
}

variable "extras" {
  description = "Additional ArgoCD apps with custom paths"
  type = map(object({
    path        = string
    values_path = string
  }))
  default = {
    "velocity-core"   = { path = "velocity", values_path = "values.yaml" }
    "gamemode-config" = { path = "gamemode-config", values_path = "values.yaml" }
  }
}

locals {
  db_services = [for name, cfg in var.services : name if cfg.has_db]
}