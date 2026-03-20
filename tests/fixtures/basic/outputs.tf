output "id" {
  description = "The created Key Vault ID."
  value       = module.key_vault.id
}

output "uri" {
  description = "The created Key Vault URI."
  value       = module.key_vault.uri
}

output "private_endpoint" {
  description = "The private endpoint output from the root module."
  value       = module.key_vault.private_endpoint
}
