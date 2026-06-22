output "host_pool_id" {
  description = "ID du Host Pool"
  value       = azurerm_virtual_desktop_host_pool.this.id
}

output "host_pool_name" {
  description = "Nom du Host Pool"
  value       = azurerm_virtual_desktop_host_pool.this.name
}

output "registration_token" {
  description = "Token d'enregistrement des Session Hosts (sensible, consomme par le module Avd/SessionHost)"
  value       = azurerm_virtual_desktop_host_pool_registration_info.this.token
  sensitive   = true
}

output "registration_expiration_date" {
  description = "Date d'expiration du token d'enregistrement (RFC3339)"
  value       = azurerm_virtual_desktop_host_pool_registration_info.this.expiration_date
}
