output "keyvault_id" {
  description = "ID du Key Vault"
  value       = azurerm_key_vault.keyvault.id
}

output "keyvault_name" {
  description = "Nom du Key Vault"
  value       = azurerm_key_vault.keyvault.name
}

output "keyvault_uri" {
  description = "URI du Key Vault"
  value       = azurerm_key_vault.keyvault.vault_uri
}
