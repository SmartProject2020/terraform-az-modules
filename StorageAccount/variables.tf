# ==============================================================================
# Variables du module StorageAccount
# ==============================================================================

variable "resource_group_name" {
  description = "Nom du Resource Group cible"
  type        = string
}

variable "location" {
  description = "Region Azure du Storage Account"
  type        = string
}

variable "storage_account_name" {
  description = "Nom du Storage Account"
  type        = string
}

variable "storage_account_tier" {
  description = "Tier (Standard ou Premium)"
  type        = string
  default     = "Standard"
}

variable "storage_account_kind" {
  description = "Kind (StorageV2, BlobStorage, FileStorage)"
  type        = string
  default     = "StorageV2"
}

variable "storage_account_replication_type" {
  description = "Type de replication (LRS, ZRS, GRS)"
  type        = string
}

variable "storage_account_access_tier" {
  description = "Access tier (Hot ou Cool)"
  type        = string
  default     = "Hot"
}

variable "blob_delete_retention_policy_days" {
  description = "Retention des blobs supprimes (jours)"
  type        = number
  default     = 7
}

variable "container_delete_retention_policy_days" {
  description = "Retention des containers supprimes (jours)"
  type        = number
  default     = 7
}

variable "network_rules_action" {
  description = "Action par defaut des regles reseau (Allow ou Deny)"
  type        = string
  default     = "Allow"
}

variable "add_network" {
  description = "Activer les regles reseau via subnet (deprecie)"
  type        = bool
  default     = false
}

variable "selected_network_name" {
  type    = string
  default = ""
}

variable "selected_subnet_name" {
  type    = string
  default = ""
}

variable "selected_network_rg_name" {
  type    = string
  default = ""
}

variable "allowed_subnet_ids" {
  description = "Liste des Subnet IDs autorises"
  type        = list(string)
  default     = []
}

variable "public_network_access_enabled" {
  description = "Acces reseau public active"
  type        = bool
  default     = true
}

variable "sftp_enabled" {
  description = "Activer SFTP"
  type        = bool
  default     = false
}

variable "is_hns_enabled" {
  description = "Activer le Hierarchical Namespace (requis pour SFTP)"
  type        = bool
  default     = false
}

variable "servier_environment" {
  description = "Environnement Servier pour le tag (ex: DEV, PRD)"
  type        = string
  default     = ""
}

variable "APPLICATION_ID" {
  description = "Identifiant de l application"
  type        = string
  default     = ""
}

variable "enable_aadkerb" {
  description = "Activer l authentification Kerberos Azure AD (AADKERB) pour Azure Files"
  type        = bool
  default     = false
}

variable "aadkerb_default_share_permission" {
  description = "Permission par defaut pour tous les utilisateurs Entra ID authentifies sur les fileshares (AADKERB uniquement). Valeurs : None, StorageFileDataSmbShareReader, StorageFileDataSmbShareContributor, StorageFileDataSmbShareElevatedContributor"
  type        = string
  default     = "None"
}
