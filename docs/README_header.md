# Azure Key Vault

Terraform module to provision an Azure Key Vault with configurable access policies or RBAC assignments, and optional private endpoint integration.

## Permissions

To provision the Azure resources managed by this module, the identity running Terraform needs permissions such as:

- Key Vault management (create/update/delete).
- Key Vault access policy and/or RBAC role assignment management.
- Private endpoint and private DNS zone group management (if used).
- Resource group read and write access where resources are created.

## Authentications

Authenticate to Azure using one of the supported AzureRM provider methods:

- Azure CLI (`az login`) for local development.
- Service principal with client secret or certificate.
- Managed identity when running in Azure.
- Environment variables (`ARM_CLIENT_ID`, `ARM_CLIENT_SECRET`, `ARM_TENANT_ID`, `ARM_SUBSCRIPTION_ID`).

## Features

- Create and configure an Azure Key Vault with secure defaults.
- Configure access with either access policies or RBAC role assignments.
- Optional inline access policies on the Key Vault resource.
- Optional private endpoint with DNS zone group and static IP configuration.

## Usage example

```hcl
module "keyvault" {
  source  = "app.terraform.io/benoitblais-hashicorp/terraform-azurerm-keyvault/azurerm"
  version = "0.0.0"

  name                = "kvexample123"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  access_configurations = [
    {
      object_id               = data.azurerm_client_config.this.object_id
      key_permissions         = ["Get", "List"]
      secret_permissions      = ["Get", "List", "Set"]
      certificate_permissions = ["Get", "List", "Create", "Update"]
    }
  ]
}
```

## Usage example with private endpoint

```hcl
module "keyvault" {
  source  = "app.terraform.io/benoitblais-hashicorp/terraform-azurerm-keyvault/azurerm"
  version = "0.0.0"

  name                = "kvexample123"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  private_endpoint = {
    name                = "pe-kvexample123"
    location            = azurerm_resource_group.example.location
    resource_group_name = azurerm_resource_group.example.name
    subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/virtualNetworks/vnet-main/subnets/snet-private"
    private_service_connection = {
      name                           = "psc-kvexample123"
      is_manual_connection           = false
      private_connection_resource_id = null
      subresource_names              = ["vault"]
    }
    private_dns_zone_group = [
      {
        name                 = "default"
        private_dns_zone_ids = ["/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-network/providers/Microsoft.Network/privateDnsZones/privatelink.vaultcore.azure.net"]
      }
    ]
  }
}
```
