<!-- BEGIN_TF_DOCS -->
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
provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "example"
  location = "canadacentral"
}

data "azurerm_client_config" "this" {}

module "keyvault" {
  source  = "app.terraform.io/benoitblais-hashicorp/terraform-azurerm-keyvault/azurerm"
  version = "0.0.0"

  name                        = "example"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_deployment      = true
  enabled_for_disk_encryption = true
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

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.3.1)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 3.54.0)

## Modules

No modules.

## Required Inputs

The following input variables are required:

### <a name="input_location"></a> [location](#input\_location)

Description: (Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created.

Type: `string`

### <a name="input_name"></a> [name](#input\_name)

Description: (Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created. The name must be globally unique. If the vault is in a recoverable state then the vault will need to be purged before reusing the name.

Type: `string`

### <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name)

Description: (Required) The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created.

Type: `string`

## Optional Inputs

The following input variables are optional (have default values):

### <a name="input_admin_objects_ids"></a> [admin\_objects\_ids](#input\_admin\_objects\_ids)

Description: IDs of the objects that can do all operations on all keys, secrets and certificates.

Type: `list(string)`

Default: `[]`

### <a name="input_contacts"></a> [contacts](#input\_contacts)

Description:   (Optional) One or more contact block as defined below.  
    email = (Required) E-mail address of the contact.  
    name  = (Optional) Name of the contact.  
    phone = (Optional) Phone number of the contact.

Type:

```hcl
list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
```

Default: `[]`

### <a name="input_enable_rbac_authorization"></a> [enable\_rbac\_authorization](#input\_enable\_rbac\_authorization)

Description: (Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions.

Type: `bool`

Default: `false`

### <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment)

Description: (Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.

Type: `bool`

Default: `false`

### <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption)

Description: (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.

Type: `bool`

Default: `false`

### <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment)

Description: (Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault

Type: `bool`

Default: `false`

### <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls)

Description:   (Optional) A network\_acls block as defined below.  
    bypass                     = (Required) Specifies which traffic can bypass the network rules. Possible values are `AzureServices` and `None`.  
    default\_action             = (Required) The Default Action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`. Possible values are `Allow` and `Deny`.  
    ip\_rules                   = (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.  
    virtual\_network\_subnet\_ids = (Optional) One or more Subnet IDs which should be able to access this Key Vault.

Type:

```hcl
object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = optional(list(string)),
    virtual_network_subnet_ids = optional(list(string)),
  })
```

Default: `null`

### <a name="input_public_network_access_enabled"></a> [public\_network\_access\_enabled](#input\_public\_network\_access\_enabled)

Description: (Optional) Whether public network access is allowed for this Key Vault.

Type: `bool`

Default: `true`

### <a name="input_purge_protection_enabled"></a> [purge\_protection\_enabled](#input\_purge\_protection\_enabled)

Description: (Optional) Is Purge Protection enabled for this Key Vault?

Type: `bool`

Default: `false`

### <a name="input_reader_objects_ids"></a> [reader\_objects\_ids](#input\_reader\_objects\_ids)

Description: IDs of the objects that can read all keys, secrets and certificates.

Type: `list(string)`

Default: `[]`

### <a name="input_sku_name"></a> [sku\_name](#input\_sku\_name)

Description: (Required) The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`.

Type: `string`

Default: `"standard"`

### <a name="input_soft_delete_retention_days"></a> [soft\_delete\_retention\_days](#input\_soft\_delete\_retention\_days)

Description: (Optional) The number of days that items should be retained for once soft-deleted. This value can be between `7` and `90` days.

Type: `number`

Default: `7`

### <a name="input_tags"></a> [tags](#input\_tags)

Description: (Optional) A mapping of tags to assign to the resource.

Type: `map(string)`

Default: `{}`

## Resources

The following resources are used by this module:

- [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_access_policy.admin_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_key_vault_access_policy.readers_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_role_assignment.rbac_keyvault_administrator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.rbac_keyvault_reader](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_role_assignment.rbac_keyvault_secrets_users](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Key Vault.

### <a name="output_keyvault"></a> [keyvault](#output\_keyvault)

Description: Azure Key Vault resource.

### <a name="output_uri"></a> [uri](#output\_uri)

Description: The URI of the Key Vault, used for performing operations on keys and secrets.

<!-- markdownlint-enable -->

<!-- END_TF_DOCS -->