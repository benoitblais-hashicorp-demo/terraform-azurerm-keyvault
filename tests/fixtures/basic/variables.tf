variable "key_vault_name" {
  description = "The Key Vault name to create."
  type        = string
}

variable "location" {
  description = "The Azure location for the resource group and key vault."
  type        = string
}

variable "resource_group_name" {
  description = "The resource group name to create for test resources."
  type        = string
}
