output "subnet_id" {
  description = "ID du subnet cree, a consommer par Avd/SessionHost (NIC) et par le stockage FSLogix"
  value       = azurerm_subnet.this.id
}

output "subnet_name" {
  description = "Nom du subnet cree"
  value       = azurerm_subnet.this.name
}

output "subnet_address_prefix" {
  description = "CIDR /24 alloue automatiquement au Host Pool"
  value       = local.next_cidr
}

output "route_table_id" {
  description = "ID de la Route Table associee au subnet"
  value       = data.azurerm_route_table.this.id
}

output "vnet_location" {
  description = "Region Azure du VNET (= region des VMs/NICs qui doivent etre dans le meme region que le subnet)"
  value       = data.azurerm_resource_group.vnet_rg.location
}
