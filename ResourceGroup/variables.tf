variable "name" {
  description = "Nom du Resource Group"
  type        = string
}

variable "location" {
  description = "Région Azure"
  type        = string
}

variable "application_id" {
  description = "Identifiant de l'application (tag application-id)"
  type        = string
}

variable "backup_policy" {
  description = "Politique de backup : PROD ou NONPROD (tag backup-policy)"
  type        = string

  validation {
    condition     = contains(["PROD", "NONPROD"], var.backup_policy)
    error_message = "backup_policy doit être PROD ou NONPROD."
  }
}

variable "servier_environment" {
  description = "Environnement Servier (tag servier-environment)"
  type        = string
}
