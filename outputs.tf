# ------------------------------------------------------------------------------
# Outputs
# ------------------------------------------------------------------------------

output "keyvault" {
  description = "Azure Key Vault resource."
  value       = azurerm_key_vault.this
}

output "id" {
  description = "The ID of the Key Vault."
  value       = azurerm_key_vault.this.id
}

output "uri" {
  description = "The URI of the Key Vault, used for performing operations on keys and secrets."
  value       = azurerm_key_vault.this.vault_uri
}

output "private_endpoint" {
  description = "The private endpoint resource if created."
  value       = try(azurerm_private_endpoint.this["default"], null)
}

output "private_endpoint_custom_dns_configs" {
  description = "The private endpoint custom DNS configs if created."
  value       = try(azurerm_private_endpoint.this["default"].custom_dns_configs, null)
}

output "private_endpoint_id" {
  description = "The private endpoint ID if created."
  value       = try(azurerm_private_endpoint.this["default"].id, null)
}

output "private_endpoint_ip_configuration" {
  description = "The private endpoint IP configuration blocks if created."
  value       = try(azurerm_private_endpoint.this["default"].ip_configuration, null)
}

output "private_endpoint_network_interface" {
  description = "The private endpoint network interface block if created."
  value       = try(azurerm_private_endpoint.this["default"].network_interface, null)
}

output "private_endpoint_network_interface_id" {
  description = "The private endpoint network interface ID if created."
  value       = try(azurerm_private_endpoint.this["default"].network_interface[0].id, null)
}

output "private_endpoint_network_interface_name" {
  description = "The private endpoint network interface name if created."
  value       = try(azurerm_private_endpoint.this["default"].network_interface[0].name, null)
}

output "private_endpoint_private_dns_zone_configs" {
  description = "The private endpoint private DNS zone configs if created."
  value       = try(azurerm_private_endpoint.this["default"].private_dns_zone_configs, null)
}

output "private_endpoint_private_service_connection_private_ip_address" {
  description = "The private endpoint private service connection private IP address if created."
  value       = try(azurerm_private_endpoint.this["default"].private_service_connection[0].private_ip_address, null)
}