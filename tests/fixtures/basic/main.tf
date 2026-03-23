resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}

module "key_vault" {
  source = "../../.."

  name                = var.key_vault_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
}
