data "azurerm_client_config" "current" {}
 
data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}
 
resource "azurerm_key_vault" "keyvault" {
  name                            = var.keyvault_name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = "standard"
  soft_delete_retention_days      = 7
  purge_protection_enabled        = true
  public_network_access_enabled   = false
  enable_rbac_authorization       = true
  enabled_for_deployment          = false
  enabled_for_disk_encryption     = false
  enabled_for_template_deployment = false
 
  network_acls {
    bypass         = "AzureServices"
    default_action = "Deny"
  }
 
  tags = local.common_tags
}