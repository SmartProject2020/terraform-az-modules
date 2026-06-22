variable "resource_group_name" {
  description = "Resource Group du Host Pool dans lequel deployer les Session Hosts"
  type        = string
}

variable "location" {
  description = "Region Azure"
  type        = string
}

# ------------------------------------------------------------------------------
# Identification / nommage — convention HLD v0.1 section 2.2 : <AVD><HostPoolID>-<n>
# Le prefixe complet (ex: "AVDMADMSYS1") est calcule par le module racine ;
# le nom Windows (computer_name) est tronque a 15 caracteres (limite NetBIOS).
# ------------------------------------------------------------------------------
variable "name_prefix" {
  description = "Prefixe de nommage des Session Hosts, ex: AVD<HostPoolID>"
  type        = string
}

variable "session_host_count" {
  description = "Nombre de Session Hosts a creer/maintenir"
  type        = number

  validation {
    condition     = var.session_host_count >= 0
    error_message = "session_host_count doit etre >= 0."
  }
}

variable "start_index" {
  description = "Numero incremental de depart (permet d'ajouter des hosts sans recreer les existants)"
  type        = number
  default     = 1
}

# ------------------------------------------------------------------------------
# Machine virtuelle
# ------------------------------------------------------------------------------
variable "vm_size" {
  description = "Taille (SKU) des VM Session Host"
  type        = string
}

variable "admin_username" {
  description = "Nom d'utilisateur administrateur local"
  type        = string
}

variable "admin_password" {
  description = "Mot de passe administrateur local (sensible — recupere depuis le Key Vault du pool)"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
  description = "ID du subnet existant (couche reseau/landing zone geree par l'equipe plateforme — TAD section 8.3.2)"
  type        = string
}

variable "zones" {
  description = "Availability Zones disponibles pour les Session Hosts (ex: [\"1\",\"2\",\"3\"] en PRD, [] en DEV). Repartition round-robin par index."
  type        = list(string)
  default     = []
}

variable "os_disk_type" {
  description = "Type de disque managed (storage_account_type) du disque OS"
  type        = string
  default     = "Premium_LRS"
}

variable "source_image_reference" {
  description = "Image marketplace du Session Host (catalogue Microsoft AVD — TAD section 8.1.1)"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
}

# ------------------------------------------------------------------------------
# Jonction identite + enregistrement AVD
# ------------------------------------------------------------------------------
variable "entra_id_join" {
  description = "Jonction Microsoft Entra ID (alternative au domain join AD classique — TAD 3.3 'Entra ID uniquement')"
  type        = bool
  default     = true
}

variable "host_pool_name" {
  description = "Nom du Host Pool auquel rattacher les Session Hosts"
  type        = string
}

variable "registration_token" {
  description = "Token d'enregistrement du Host Pool (sensible, fourni par le module HostPool)"
  type        = string
  sensitive   = true
}

variable "avd_agent_package_url" {
  description = "URL du package DSC contenant l'agent AVD (Configuration.zip — verifier la derniere version sur learn.microsoft.com)"
  type        = string
}

# ------------------------------------------------------------------------------
# Tagging
# ------------------------------------------------------------------------------
variable "APPLICATION_ID" {
  description = "Identifiant applicatif (tag application-id)"
  type        = string
}

variable "servier_environment" {
  description = "Environnement Servier (tag servier-environment)"
  type        = string
}

variable "backup_policy" {
  description = "Politique de sauvegarde (PROD/NONPROD, tag backup-policy)"
  type        = string
}
