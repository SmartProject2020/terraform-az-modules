data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_virtual_desktop_host_pool" "this" {
  name                = var.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  type                             = var.type
  load_balancer_type               = var.load_balancer_type
  personal_desktop_assignment_type = local.personal_desktop_assignment_type
  maximum_sessions_allowed         = local.maximum_sessions_allowed

  friendly_name         = var.friendly_name
  description           = var.description
  start_vm_on_connect   = var.start_vm_on_connect
  validate_environment  = var.validate_environment
  custom_rdp_properties = var.custom_rdp_properties

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Le token d'enregistrement est necessaire pour joindre des Session Hosts au
# Host Pool (cf. module Avd/SessionHost). time_rotating le renouvelle
# automatiquement a expiration, sans recreer le Host Pool a chaque apply.
resource "time_rotating" "registration_expiration" {
  rotation_hours = var.registration_expiration_hours
}

resource "azurerm_virtual_desktop_host_pool_registration_info" "this" {
  hostpool_id     = azurerm_virtual_desktop_host_pool.this.id
  expiration_date = time_rotating.registration_expiration.rotation_rfc3339
}
