# ==============================================================================
# Module enfant : Fileshare
# Cree uniquement les Azure File Shares sur un Storage Account existant.
# Le SA est passe en input via storage_account_id (pas cree ici).
#
# Convention de nommage : ${APPLICATION_ID}-${share_name}
#   Exemple : APP_ID=nxgen, share=logs   ->  nxgen-logs
# ==============================================================================

locals {
  # Construction des noms finaux : prefixe APPLICATION_ID
  fileshare_names = {
    for name in var.fileshares :
    name => lower("${var.APPLICATION_ID}-${name}")
  }

  # Premium FileStorage impose un minimum de 100 GiB par fileshare
  effective_quota_gb = max(var.quota_gb, 100)
}

resource "azurerm_storage_share" "share" {
  for_each = local.fileshare_names

  name               = each.value
  storage_account_id = var.storage_account_id
  quota              = local.effective_quota_gb

  lifecycle {
    # prevent_destroy = true
  }
}
