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

output "network_security_group_id" {
  description = "ID du Network Security Group associe au subnet"
  value       = azurerm_network_security_group.this.id
}

output "network_security_group_name" {
  description = "Nom du Network Security Group associe au subnet"
  value       = azurerm_network_security_group.this.name
}
