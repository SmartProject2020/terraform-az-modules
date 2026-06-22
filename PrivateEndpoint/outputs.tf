output "endpoint_name" {
  value = azurerm_private_endpoint.endpoint.name
}

output "endpoint_id" {
  value = azurerm_private_endpoint.endpoint.id
}

output "endpoint_ip" {
  value = azurerm_private_endpoint.endpoint.private_service_connection[0].private_ip_address
}

#output "endpoint_fqdn" {
#  value = length (azurerm_private_endpoint.endpoint.private_dns_zone_configs) > 0 ? azurerm_private_endpoint.endpoint.private_dns_zone_configs[0].record_sets[0].fqdn : null
#}