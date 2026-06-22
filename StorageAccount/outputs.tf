# ==============================================================================
# Outputs du module StorageAccount
# ==============================================================================

output "storage_account_id" {
  description = "ID complet du Storage Account"
  value       = azurerm_storage_account.storage_account.id
}

output "storage_account_name" {
  description = "Nom du Storage Account"
  value       = azurerm_storage_account.storage_account.name
}

output "primary_blob_endpoint" {
  description = "Endpoint primaire pour les blobs"
  value       = azurerm_storage_account.storage_account.primary_blob_endpoint
}

output "primary_file_endpoint" {
  description = "Endpoint primaire pour les fileshares"
  value       = azurerm_storage_account.storage_account.primary_file_endpoint
}
