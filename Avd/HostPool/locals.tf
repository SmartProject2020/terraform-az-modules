locals {
  # Le pool Personal n'utilise pas maximum_sessions_allowed, le pool Pooled
  # n'utilise pas personal_desktop_assignment_type : on neutralise selon le type
  # pour eviter les incoherences acceptees silencieusement par le provider.
  maximum_sessions_allowed         = var.type == "Pooled" ? var.maximum_sessions_allowed : null
  personal_desktop_assignment_type = var.type == "Personal" ? var.personal_desktop_assignment_type : null

  common_tags = merge(
    data.azurerm_resource_group.rg.tags,
    {
      "managed-by"          = "terraform"
      "module"              = "avd-hostpool"
      "application-id"      = var.APPLICATION_ID
      "backup-policy"       = var.backup_policy
      "servier-environment" = var.servier_environment
    }
  )
}
