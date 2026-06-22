locals {
  # Nom complet de la ressource Azure (peut depasser 15 caracteres)
  vm_names = [
    for i in range(var.session_host_count) : "${upper(var.name_prefix)}-${var.start_index + i}"
  ]

  # Nom Windows (computer_name) — limite NetBIOS a 15 caracteres
  computer_names = [for n in local.vm_names : substr(n, 0, 15)]

  common_tags = merge(data.azurerm_resource_group.rg.tags, {
    "managed-by"          = "terraform"
    "module"              = "avd-sessionhost"
    "application-id"      = var.APPLICATION_ID
    "backup-policy"       = var.backup_policy
    "servier-environment" = var.servier_environment
  })
}
