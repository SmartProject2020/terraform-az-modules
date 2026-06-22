locals {
  common_tags = merge(
    data.azurerm_resource_group.rg.tags,
    {
      "managed-by"         = "terraform"
      "module"             = "keyvault"
      "application-id"     = var.APPLICATION_ID
      "backup-policy"      = var.backup_policy
      "servier-environment" = var.servier_environment
    }
  )
}
