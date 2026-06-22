# ==============================================================================
# Variables required
# ==============================================================================
 
variable "resource_group_name" {
  description = "Nom du Resource Group cible"
  type        = string
}
 
variable "keyvault_name" {
  description = "Nom du Key Vault"
  type        = string
}
 
variable "APPLICATION_ID" {
  description = "Identifiant de l'application"
  type        = string
}
 
variable "servier_environment" {
  description = "Environnement Servier (ex: DEV, PRD)"
  type        = string
}
 
variable "backup_policy" {
  description = "Politique de backup (PROD ou NONPROD)"
  type        = string
}
 
variable "SETTING" {
  description = "Setting NPR ou PRD — utilisé pour le choix de l object_id appgateway"
  type        = string
}
