# ==============================================================================
# Outputs du module Fileshare
# ==============================================================================

output "fileshare_ids" {
  description = "Map des IDs des fileshares crees (cle = nom court, valeur = ID)"
  value       = { for k, v in azurerm_storage_share.share : k => v.id }
}

output "fileshare_names" {
  description = "Map des noms finaux des fileshares (cle = nom court, valeur = nom complet avec prefixe)"
  value       = { for k, v in azurerm_storage_share.share : k => v.name }
}

output "fileshare_resource_manager_ids" {
  description = "Map des Resource Manager IDs des fileshares (utilises pour le AD join)"
  value       = { for k, v in azurerm_storage_share.share : k => v.resource_manager_id }
}
