# ==============================================================================
# Module enfant : StorageAccount
# Cree uniquement le Storage Account (pas de fileshares).
# Les fileshares sont geres par le module Fileshare separe.
# ==============================================================================

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_subnet" "selected_network_subnet" {
  count = (var.add_network && var.network_rules_action == "Deny") ? 1 : 0

  name                 = var.selected_subnet_name
  virtual_network_name = var.selected_network_name
  resource_group_name  = var.selected_network_rg_name
}

resource "azurerm_storage_account" "storage_account" {
  name                            = var.storage_account_name
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  account_tier                    = var.storage_account_tier
  account_kind                    = var.storage_account_kind
  account_replication_type        = var.storage_account_replication_type
  access_tier                     = var.storage_account_access_tier
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = var.public_network_access_enabled
  https_traffic_only_enabled      = true
  shared_access_key_enabled       = true
  default_to_oauth_authentication = true
  large_file_share_enabled        = local.large_file_share_enabled
  local_user_enabled              = false
  sftp_enabled                    = var.sftp_enabled
  is_hns_enabled                  = var.is_hns_enabled
  allow_nested_items_to_be_public = false

  dynamic "blob_properties" {
    for_each = contains(["StorageV2", "BlobStorage"], var.storage_account_kind) ? [1] : []
    content {
      delete_retention_policy {
        days = var.blob_delete_retention_policy_days
      }
      container_delete_retention_policy {
        days = var.container_delete_retention_policy_days
      }
    }
  }

  dynamic "azure_files_authentication" {
    for_each = var.enable_aadkerb ? [1] : []
    content {
      directory_type                 = "AADKERB"
      default_share_level_permission = var.aadkerb_default_share_permission
    }
  }

  network_rules {
    default_action             = var.network_rules_action
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = local.virtual_network_subnet_ids
  }

  tags = local.common_tags

  lifecycle {
    # prevent_destroy = true
    ignore_changes  = [network_rules]
  }
}
