# ==============================================================================
# Variables du module Fileshare
# ==============================================================================

variable "storage_account_id" {
  description = "ID complet du Storage Account existant qui hebergera les fileshares"
  type        = string
}

variable "fileshares" {
  description = "Liste des noms de fileshares a creer (sans prefixe, le module ajoute APPLICATION_ID-)"
  type        = set(string)
}

variable "APPLICATION_ID" {
  description = "Identifiant de l application (utilise comme prefixe des fileshares)"
  type        = string
}

variable "quota_gb" {
  description = "Quota global applique a tous les fileshares (en GB)"
  type        = number
  default     = 100
}

variable "provisioned_iops" {
  description = "IOPS provisionnees par fileshare (V2 uniquement). Minimum Azure : 3000. null = V1 (non applicable)."
  type        = number
  default     = null
}

variable "provisioned_bandwidth_mibps" {
  description = "Bande passante provisionnee par fileshare en MiB/s (V2 uniquement). null = minimum Azure (125 MiB/s a 3000 IOPS)."
  type        = number
  default     = null
}
