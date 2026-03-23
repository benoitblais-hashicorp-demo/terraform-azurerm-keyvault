# Azure Key Vault Terraform Module

Terraform module to provision an Azure Key Vault with configurable access policies or RBAC assignments, and optional private endpoint integration.

## Permissions

To provision the Azure resources managed by this module, the identity running Terraform needs permissions such as:

- `Contributor` (for resource group and Key Vault/Private Endpoint resource lifecycle operations).
- `User Access Administrator` (required if this module creates `azurerm_role_assignment` resources).
- `Key Vault Contributor` (optional scoped alternative for Key Vault management, when not using broad Contributor at scope).
- `Network Contributor` (required on the target virtual network/subnet used by private endpoints).
- `Private DNS Zone Contributor` (required when managing private DNS zone groups and zone records linked to private endpoints).

## Authentications

Authentication to Azure can be configured using one of the following methods:

### Service Principal and Client Secret

Use an Azure AD service principal for non-interactive runs (CI/CD, automation).

You can configure this method in either of the following ways:

- **Inside the provider block**

  ```hcl
  provider "azurerm" {
    features {}

    subscription_id = "<subscription-id>"
    tenant_id       = "<tenant-id>"
    client_id       = "<client-id>"
    client_secret   = "<client-secret>"
  }
  ```

- **Using environment variables**

  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID`
  - `ARM_CLIENT_ID`
  - `ARM_CLIENT_SECRET`

### Managed Service Identity

Use Managed Identity when Terraform runs on Azure-hosted compute (for example, Azure VM, VMSS, App Service, AKS).

- **Inside the provider block**

  ```hcl
  provider "azurerm" {
    features {}
    use_msi = true
  }
  ```

- **Using environment variables**

  - `ARM_USE_MSI=true`
  - `ARM_SUBSCRIPTION_ID`
  - `ARM_TENANT_ID` (optional in some environments, but recommended for clarity)

Documentation:

- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs#authenticating-to-azure
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
- https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/managed_service_identity

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
