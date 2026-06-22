# ==============================================================================
# Variables required
# ==============================================================================

variable "resource_group_name" {
  description = "Nom du Resource Group cible (dedie au Host Pool)"
  type        = string
}

variable "location" {
  description = "Region Azure du Host Pool (peut differer de celle du Resource Group)"
  type        = string
}

variable "name" {
  description = "Nom du Host Pool, convention HLD v0.1 : <M|P><PoolID><version> (ex: MADMSYS1)"
  type        = string
}

variable "type" {
  description = "Type de Host Pool : Pooled (multisession) ou Personal"
  type        = string

  validation {
    condition     = contains(["Pooled", "Personal"], var.type)
    error_message = "type doit etre Pooled ou Personal."
  }
}

variable "load_balancer_type" {
  description = "Algorithme de repartition de charge : BreadthFirst, DepthFirst ou Persistent (Personal uniquement)"
  type        = string

  validation {
    condition     = contains(["BreadthFirst", "DepthFirst", "Persistent"], var.load_balancer_type)
    error_message = "load_balancer_type doit etre BreadthFirst, DepthFirst ou Persistent."
  }
}

# ==============================================================================
# Variables optionnelles
# ==============================================================================

variable "friendly_name" {
  description = "Nom convivial affiche aux utilisateurs"
  type        = string
  default     = null
}

variable "description" {
  description = "Description du Host Pool"
  type        = string
  default     = null
}

variable "personal_desktop_assignment_type" {
  description = "Mode d'attribution pour un pool Personal : Automatic ou Direct (ignore si type = Pooled)"
  type        = string
  default     = null

  validation {
    condition     = contains(["Automatic", "Direct"], coalesce(var.personal_desktop_assignment_type, "Automatic"))
    error_message = "personal_desktop_assignment_type doit etre Automatic ou Direct."
  }
}

variable "maximum_sessions_allowed" {
  description = "Nombre maximum de sessions par session host (Pooled uniquement, ignore si type = Personal)"
  type        = number
  default     = null
}

variable "start_vm_on_connect" {
  description = "Active le demarrage automatique des session hosts a la connexion utilisateur"
  type        = bool
  default     = true
}

variable "validate_environment" {
  description = "Bascule le Host Pool en environnement de validation"
  type        = bool
  default     = false
}

variable "custom_rdp_properties" {
  description = "Proprietes RDP personnalisees (ex: optimisations reseau RDP ShortPath - section 3.8 du TAD)"
  type        = string
  default     = null
}

variable "registration_expiration_hours" {
  description = "Duree de validite (en heures) du token d'enregistrement des session hosts, renouvele automatiquement"
  type        = number
  default     = 8
}

# ==============================================================================
# Tags (propages depuis le Resource Group + tags specifiques module)
# ==============================================================================

variable "APPLICATION_ID" {
  description = "Identifiant de l'application (tag application-id)"
  type        = string
}

variable "servier_environment" {
  description = "Environnement Servier (tag servier-environment)"
  type        = string
}

variable "backup_policy" {
  description = "Politique de backup : PROD ou NONPROD (tag backup-policy)"
  type        = string
}
