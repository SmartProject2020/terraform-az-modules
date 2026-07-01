locals {
  dns_names = {
    sqlServer        = "privatelink.database.windows.net"
    blob             = "privatelink.blob.core.windows.net"
    file             = "privatelink.file.core.windows.net"
    queue            = "privatelink.queue.core.windows.net"
    table            = "privatelink.table.core.windows.net"
    web              = "privatelink.web.core.windows.net"
    sites            = "privatelink.azurewebsites.net"
    dfs              = "privatelink.dfs.core.windows.net"
    mariadbServer    = "privatelink.mariadb.database.azure.com"
    registry         = "privatelink.azurecr.io"
    postgresqlServer = "privatelink.postgres.database.azure.com"
    vault            = "privatelink.vaultcore.azure.net"
    containerRegistry = "privatelink.registry.azurecr.io"
  }
}

data "azurerm_private_dns_zone" "zone" {
  provider = azurerm.hub_subscription
  name     = local.dns_names[var.resource_type]
}

data "azurerm_resource_group" "rg_vnet" {
  name = var.resource_group_name_vnet
}

data "azurerm_subnet" "subnet" {
  name                 = var.subnet_name
  virtual_network_name = var.network_name
  resource_group_name  = data.azurerm_resource_group.rg_vnet.name
}

data "azurerm_resource_group" "rg_private_endpoint" {
  name = var.resource_group_name
}

resource "azurerm_private_endpoint" "endpoint" {
  name                          = var.endpoint_name
  location                      = data.azurerm_resource_group.rg_private_endpoint.location
  resource_group_name           = data.azurerm_resource_group.rg_private_endpoint.name
  subnet_id                     = data.azurerm_subnet.subnet.id
  custom_network_interface_name = var.custom_network_interface_name

  private_dns_zone_group {
    name                 = local.dns_names[var.resource_type]
    private_dns_zone_ids = [data.azurerm_private_dns_zone.zone.id]
  }

  private_service_connection {
    name                           = "${var.endpoint_name}-connection"
    private_connection_resource_id = var.connection_resource_id
    is_manual_connection           = var.is_manual_connection
    subresource_names              = [var.resource_type]
  }

  tags = merge(data.azurerm_resource_group.rg_private_endpoint.tags, var.tags)

  depends_on = [
    data.azurerm_subnet.subnet,
    data.azurerm_private_dns_zone.zone
  ]
}
