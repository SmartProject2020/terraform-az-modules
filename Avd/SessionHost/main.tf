# ==============================================================================
# Child module : Avd/SessionHost
# Gere : NIC + VM Windows + jonction Entra ID + enregistrement aupres du Host Pool
#
# Nommage (TAD section 2.2) : <AVD><HostPoolID>-<incremental-number>
# Le computer_name Windows est tronque a 15 caracteres (limite NetBIOS).
# ==============================================================================

data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

resource "azurerm_network_interface" "this" {
  count = var.session_host_count

  name                = "${local.vm_names[count.index]}-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.common_tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_windows_virtual_machine" "this" {
  count = var.session_host_count

  name                = local.vm_names[count.index]
  computer_name       = local.computer_names[count.index]
  resource_group_name = var.resource_group_name
  location            = var.location
  size                = var.vm_size
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  zone                = length(var.zones) > 0 ? var.zones[count.index % length(var.zones)] : null

  network_interface_ids = [azurerm_network_interface.this[count.index].id]

  identity {
    type = "SystemAssigned"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = var.os_disk_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }

  tags = local.common_tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Jonction Microsoft Entra ID — remplace le domain join AD classique (TAD 3.3 "Entra ID uniquement ?")
resource "azurerm_virtual_machine_extension" "aadlogin" {
  count = var.entra_id_join ? var.session_host_count : 0

  name                       = "AADLoginForWindows"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Azure.ActiveDirectory"
  type                       = "AADLoginForWindows"
  type_handler_version       = "2.2"
  auto_upgrade_minor_version = true

  # mdmId = ID d'application Microsoft Intune (constante Microsoft) — declenche
  # l'enrollment MDM automatique a la jonction Entra ID (TAD section 7 : Intune
  # exclusif pour les machines Windows 11).
  settings = var.intune_enrollment_enabled ? jsonencode({
    mdmId = "0000000a-0000-0000-c000-000000000000"
  }) : null

  tags = local.common_tags
}

# Enregistrement du Session Host aupres du Host Pool — agent AVD via extension DSC
# (token d'enregistrement transmis en protected_settings, jamais logge)
resource "azurerm_virtual_machine_extension" "avd_registration" {
  count = var.session_host_count

  name                       = "Microsoft.PowerShell.DSC"
  virtual_machine_id         = azurerm_windows_virtual_machine.this[count.index].id
  publisher                  = "Microsoft.Powershell"
  type                       = "DSC"
  type_handler_version       = "2.73"
  auto_upgrade_minor_version = true

  settings = jsonencode({
    modulesUrl            = var.avd_agent_package_url
    configurationFunction = "Configuration.ps1\\AddSessionHost"
    properties = {
      hostPoolName = var.host_pool_name
      aadJoin      = var.entra_id_join
    }
  })

  protected_settings = jsonencode({
    properties = {
      registrationInfoToken = var.registration_token
    }
  })

  tags = local.common_tags

  depends_on = [azurerm_virtual_machine_extension.aadlogin]
}
