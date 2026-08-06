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

variable "os_disk_size_gb" {
  description = "Taille du disque OS en GiB"
  type        = number
  default     = 128
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

variable "intune_enrollment_enabled" {
  description = "Declenche l'enrollment MDM Intune (mdmId) a la jonction Entra ID — TAD section 7, Intune exclusif pour Windows 11"
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

# ------------------------------------------------------------------------------
# FSLogix — Profile Containers (learn.microsoft.com/fslogix/reference-configuration-settings)
# Installe l'agent FSLogix et configure les cles de registre Profile + Logging.
# ODFC (Office Container) et Cloud Cache ne sont pas geres ici : l'infra ne
# provisionne qu'un seul fileshare SMB (voir HostPool), pas de second partage
# ODFC ni de multi-provider Cloud Cache.
# ------------------------------------------------------------------------------
variable "fslogix_enabled" {
  description = "Installe et active FSLogix Profile Containers sur le Session Host"
  type        = bool
  default     = true
}

variable "fslogix_vhd_locations" {
  description = "Chemin UNC du fileshare FSLogix (ex: \\\\<storageaccount>.file.core.windows.net\\<fileshare>) — requis si fslogix_enabled=true"
  type        = string
  default     = null
}

variable "fslogix_size_in_mb" {
  description = "Taille max du VHD(x) de profil par utilisateur, en Mo (registre SizeInMBs)"
  type        = number
  default     = 30000
}

variable "fslogix_volume_type" {
  description = "Format du conteneur de profil (vhd ou vhdx)"
  type        = string
  default     = "vhdx"

  validation {
    condition     = contains(["vhd", "vhdx"], var.fslogix_volume_type)
    error_message = "fslogix_volume_type doit etre 'vhd' ou 'vhdx'."
  }
}

variable "fslogix_is_dynamic" {
  description = "VHD(x) dynamique (ne consomme que l'espace reellement utilise, jusqu'a fslogix_size_in_mb)"
  type        = bool
  default     = true
}

variable "fslogix_flip_flop_profile_directory_name" {
  description = "Nomme le dossier de profil <username>_<sid> au lieu de <sid>_<username>. SANS EFFET quand fslogix_no_profile_containing_folder=true (cf. doc Microsoft) — laisse au defaut (false) dans ce cas pour eviter un reglage redondant/trompeur."
  type        = bool
  default     = false
}

variable "fslogix_delete_local_profile_when_vhd_should_apply" {
  description = "Supprime le profil Windows local s'il existe deja quand FSLogix doit s'appliquer (recommandation Microsoft AVD, evite les conflits de profil)"
  type        = bool
  default     = true
}

variable "fslogix_access_network_as_computer_object" {
  description = "Attache le VHD(x) en tant qu'objet ordinateur au lieu de l'utilisateur (a n'activer que si le storage provider l'exige — risque de securite, cf. doc Microsoft)"
  type        = bool
  default     = false
}

variable "fslogix_keep_local_dir" {
  description = "Conserve le dossier local_%username% apres deconnexion (registre KeepLocalDir)"
  type        = bool
  default     = true
}

variable "fslogix_prevent_login_with_failure" {
  description = "Bloque la connexion (FRXShell) si l'attachement au VHD(x) de profil echoue, plutot que de laisser passer en profil temporaire silencieusement"
  type        = bool
  default     = true
}

variable "fslogix_roam_identity" {
  description = "Active le roaming legacy des donnees d'identite (registre RoamIdentity). Microsoft deconseille formellement ce reglage sur les postes Intune/Entra ID joints — laisse au defaut recommande (false)."
  type        = bool
  default     = false
}

variable "fslogix_roam_search" {
  description = "Roaming de la base de recherche Windows (registre RoamSearch : 0=off, 1=mono-utilisateur, 2=multi-utilisateur)"
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 1, 2], var.fslogix_roam_search)
    error_message = "fslogix_roam_search doit etre 0, 1 ou 2."
  }
}

variable "fslogix_no_profile_containing_folder" {
  description = "Le conteneur de profil n'utilise pas de sous-dossier par SID (registre NoProfileContainingFolder) — prioritaire sur fslogix_flip_flop_profile_directory_name si les deux sont actifs"
  type        = bool
  default     = true
}

variable "fslogix_vhd_name_match" {
  description = "Motif de recherche du fichier VHD(x) de profil existant (registre VHDNameMatch)"
  type        = string
  default     = "%username%"
}

variable "fslogix_vhd_name_pattern" {
  description = "Motif de creation du fichier VHD(x) de profil (registre VHDNamePattern) — doit correspondre a fslogix_vhd_name_match"
  type        = string
  default     = "%username%"
}

variable "fslogix_logging_enabled" {
  description = "Active la journalisation FSLogix (registre LoggingEnabled : 0=off, 1=logs par composant, 2=tous les logs)"
  type        = number
  default     = 2

  validation {
    condition     = contains([0, 1, 2], var.fslogix_logging_enabled)
    error_message = "fslogix_logging_enabled doit etre 0, 1 ou 2."
  }
}

variable "fslogix_logging_level" {
  description = "Niveau de verbosite des logs FSLogix (0=Verbose, 1=Standard, 2=Minimal, 3=Erreurs uniquement)"
  type        = number
  default     = 1

  validation {
    condition     = contains([0, 1, 2, 3], var.fslogix_logging_level)
    error_message = "fslogix_logging_level doit etre entre 0 et 3."
  }
}
