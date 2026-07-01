#
# Required Variables
#

variable "resource_group_name" {
  type        = string
  description = "Nom du groupe de ressources où sera créé le Private Endpoint"
}

variable "resource_group_name_vnet" {
  type        = string
  description = "Nom du groupe de ressources où sera créé le Private Endpoint"
}

variable "network_name" {
  type        = string
  description = "Nom du réseau virtuel contenant le sous-réseau cible"
}

variable "subnet_name" {
  type        = string
  description = "Nom du sous-réseau où le Private Endpoint sera créé"
}

variable "endpoint_name" {
  type        = string
  description = "Nom du Private Endpoint"
}

variable "connection_resource_id" {
  type        = string
  description = "ID de la ressource Azure à connecter en Private Endpoint"
}

# variable "resource_type" {
#   type        = string
#   description = "Type de la ressource Azure pour le Private Endpoint"

#   validation {
#     condition     = contains(keys(local.dns_names), var.resource_type)
#     error_message = "La valeur de 'resource_type' doit être l'une des suivantes : ${join(", ", keys(local.dns_names))}."
#   }
# }

variable "resource_type" {
  type        = string
  description = "Type de la ressource Azure pour le Private Endpoint"

  validation {
    condition     = contains([
      "sqlServer", "blob", "file", "queue", "table", "web",
      "sites", "dfs", "mariadbServer", "registry",
      "postgresqlServer", "vault", "containerRegistry"
    ], var.resource_type)

    error_message = "La valeur de 'resource_type' doit être l'une des suivantes : sqlServer, blob, file, queue, table, web, sites, dfs, mariadbServer, registry, postgresqlServer, vault, containerRegistry."
  }
}


#
# Optional Variables
#

variable "is_manual_connection" {
  type        = bool
  default     = false
  description = "Détermine si la connexion privée est manuelle"
}

variable "custom_network_interface_name" {
  type        = string
  default     = null
  description = "Nom personnalise de la NIC du Private Endpoint (ex: EM50-NPR-TEST-NIC01). Null = nom auto Azure."
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags appliqués à la ressource"
}
