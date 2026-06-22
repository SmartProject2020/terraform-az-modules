output "session_host_names" {
  description = "Noms des VM Session Host (ressources Azure)"
  value       = azurerm_windows_virtual_machine.this[*].name
}

output "session_host_ids" {
  description = "IDs des VM Session Host"
  value       = azurerm_windows_virtual_machine.this[*].id
}

output "computer_names" {
  description = "Noms Windows (computer_name, tronques a 15 caracteres)"
  value       = azurerm_windows_virtual_machine.this[*].computer_name
}

output "network_interface_ids" {
  description = "IDs des cartes reseau associees"
  value       = azurerm_network_interface.this[*].id
}
