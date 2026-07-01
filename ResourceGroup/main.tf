resource "azurerm_resource_group" "rg" {
  name     = var.name
  location = var.location

  tags = {
    application-id      = var.application_id
    backup-policy       = var.backup_policy
    servier-environment = var.servier_environment
  }
  
  lifecycle {
    prevent_destroy = true
    ignore_changes  = [location]
  }
  
}