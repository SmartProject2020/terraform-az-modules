data "azurerm_resource_group" "vnet_rg" {
  name = var.resource_group_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.virtual_network_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

# Adresses de tous les subnets existants dans le VNET, pour calculer le prochain
# /24 libre et detecter si le subnet gere par ce module (var.subnet_name) existe
# deja (cf. locals.next_cidr pour l'idempotence).
data "azurerm_subnet" "existing" {
  for_each             = toset(data.azurerm_virtual_network.vnet.subnets)
  name                 = each.value
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
}

# Route table pre-existante (geree par l'equipe reseau, pas par ce module)
data "azurerm_route_table" "this" {
  name                = var.route_table_name
  resource_group_name = data.azurerm_resource_group.vnet_rg.name
}

resource "azurerm_subnet" "this" {
  name                 = var.subnet_name
  resource_group_name  = data.azurerm_resource_group.vnet_rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name
  address_prefixes     = [local.next_cidr]

  lifecycle {
    precondition {
      condition     = length(local.available_cidrs) > 0
      error_message = "Aucun /24 disponible dans ${var.vnet_address_space} (VNET ${var.virtual_network_name}, RG ${var.resource_group_name}) : tous les blocs sont deja alloues. Ajoutez de la capacite ou revoyez la repartition standard/critical."
    }
  }
}

resource "azurerm_subnet_route_table_association" "this" {
  subnet_id      = azurerm_subnet.this.id
  route_table_id = data.azurerm_route_table.this.id
}
