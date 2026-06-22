locals {
  # Large file share : active automatiquement pour FileStorage
  large_file_share_enabled = var.storage_account_kind == "FileStorage" ? true : null

  virtual_network_subnet_ids = compact(concat(
    [for s in data.azurerm_subnet.selected_network_subnet : s.id],
    var.allowed_subnet_ids
  ))

  common_tags = {
    application_id = var.APPLICATION_ID
    servier_environment = var.servier_environment
    managed_by     = "terraform"
  }
}