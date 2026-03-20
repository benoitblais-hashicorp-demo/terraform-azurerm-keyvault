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

## Documentation

## Requirements

The following requirements are needed by this module:

- <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) (>= 1.13.0)

- <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) (~> 4.64.0)

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

### <a name="input_access_configurations"></a> [access\_configurations](#input\_access\_configurations)

Description:   (Optional) A list of Key Vault Access Policy configurations managed through separate `azurerm_key_vault_access_policy` resources.  
    tenant\_id : (Optional) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault.  
    object\_id : (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.  
    application\_id : (Optional) The object ID of an Application in Azure Active Directory.  
    certificate\_permissions : (Optional) List of certificate permissions.  
    key\_permissions : (Optional) List of key permissions.  
    secret\_permissions : (Optional) List of secret permissions.  
    storage\_permissions : (Optional) List of storage permissions.

Type:

```hcl
list(object({
    tenant_id               = optional(string)
    object_id               = string
    application_id          = optional(string)
    certificate_permissions = optional(list(string))
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
```

Default: `[]`

### <a name="input_access_policies"></a> [access\_policies](#input\_access\_policies)

Description:   (Optional) A list of access\_policy objects (up to 1024) describing access policies, as described below.  
    tenant\_id : (Optional) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault.  
    object\_id : (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.  
    application\_id : (Optional) The object ID of an Application in Azure Active Directory.  
    certificate\_permissions : (Optional) List of certificate permissions.  
    key\_permissions : (Optional) List of key permissions.  
    secret\_permissions : (Optional) List of secret permissions.  
    storage\_permissions : (Optional) List of storage permissions.

Type:

```hcl
list(object({
    tenant_id               = string
    object_id               = string
    application_id          = optional(string)
    certificate_permissions = optional(list(string))
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
```

Default: `[]`

### <a name="input_enabled_for_deployment"></a> [enabled\_for\_deployment](#input\_enabled\_for\_deployment)

Description: (Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault.

Type: `bool`

Default: `false`

### <a name="input_enabled_for_disk_encryption"></a> [enabled\_for\_disk\_encryption](#input\_enabled\_for\_disk\_encryption)

Description: (Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys.

Type: `bool`

Default: `false`

### <a name="input_enabled_for_template_deployment"></a> [enabled\_for\_template\_deployment](#input\_enabled\_for\_template\_deployment)

Description: (Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault.

Type: `bool`

Default: `false`

### <a name="input_network_acls"></a> [network\_acls](#input\_network\_acls)

Description: 	(Optional) A network\_acls block as defined below.  
		bypass : (Required) Specifies which traffic can bypass the network rules. Possible values are `AzureServices` and `None`.  
		default\_action : (Required) The Default Action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`. Possible values are `Allow` and `Deny`.  
		ip\_rules : (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.  
		virtual\_network\_subnet\_ids : (Optional) One or more Subnet IDs which should be able to access this Key Vault.

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

### <a name="input_private_endpoint"></a> [private\_endpoint](#input\_private\_endpoint)

Description:   (Optional) Private endpoint configuration. If provided, a private endpoint is created.  
    name : (Required) Specifies the Name of the Private Endpoint. Changing this forces a new resource to be created.  
    resource\_group\_name : (Required) Specifies the Name of the Resource Group within which the Private Endpoint should exist. Changing this forces a new resource to be created.  
    location : (Required) The supported Azure location where the resource exists. Changing this forces a new resource to be created.  
    subnet\_id : (Required) The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created.  
    custom\_network\_interface\_name : (Optional) The custom name of the network interface attached to the private endpoint. Changing this forces a new resource to be created.  
    tags : (Optional) A mapping of tags to assign to the resource.  
    private\_service\_connection : (Required) A `private_service_connection` block as defined below.  
      name : (Required) Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created.  
      is\_manual\_connection : (Required) Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource to be created.  
      private\_connection\_resource\_id : (Optional) The ID of the Private Link Enabled Remote Resource to connect to. One of this or `private_connection_resource_alias` must be specified.  
      private\_connection\_resource\_alias : (Optional) The Service Alias of the Private Link Enabled Remote Resource to connect to. One of this or `private_connection_resource_id` must be specified.  
      subresource\_names : (Optional) A list of subresource names which the Private Endpoint is able to connect to.  
      request\_message : (Optional) A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection. Only valid if `is_manual_connection` is `true`.  
    private\_dns\_zone\_group : (Optional) One or more `private_dns_zone_group` blocks as defined below.  
      name : (Required) Specifies the Name of the Private DNS Zone Group.  
      private\_dns\_zone\_ids : (Required) Specifies the list of Private DNS Zones to include within the `private_dns_zone_group`.  
    ip\_configuration : (Optional) One or more `ip_configuration` blocks as defined below.  
      name : (Required) Specifies the Name of the IP Configuration. Changing this forces a new resource to be created.  
      private\_ip\_address : (Required) Specifies the static IP address within the private endpoint's subnet to be used. Changing this forces a new resource to be created.  
      subresource\_name : (Optional) Specifies the subresource this IP address applies to.  
      member\_name : (Optional) Specifies the member name this IP address applies to. If it is not specified, it will use the value of `subresource_name`.

Type:

```hcl
object({
    name                          = string
    location                      = string
    resource_group_name           = string
    subnet_id                     = string
    custom_network_interface_name = optional(string)
    tags                          = optional(map(string))
    private_service_connection = object({
      name                              = string
      is_manual_connection              = bool
      private_connection_resource_id    = optional(string)
      private_connection_resource_alias = optional(string)
      subresource_names                 = optional(list(string))
      request_message                   = optional(string)
    })
    private_dns_zone_group = optional(list(object({
      name                 = string
      private_dns_zone_ids = list(string)
    })), [])
    ip_configuration = optional(list(object({
      name               = string
      private_ip_address = string
      subresource_name   = optional(string)
      member_name        = optional(string)
    })), [])
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

### <a name="input_rbac_authorization_enabled"></a> [rbac\_authorization\_enabled](#input\_rbac\_authorization\_enabled)

Description: (Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions.

Type: `bool`

Default: `false`

### <a name="input_rbac_role_assignments"></a> [rbac\_role\_assignments](#input\_rbac\_role\_assignments)

Description:   (Optional) RBAC role assignments to configure on the Key Vault when RBAC authorization is enabled.  
    principal\_id         = (Required) The principal ID to assign the role to.  
    role\_definition\_name = (Required) The built-in role name to assign (for example, `Key Vault Administrator`).

Type:

```hcl
list(object({
    principal_id         = string
    role_definition_name = string
  }))
```

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

### <a name="input_tenant_id"></a> [tenant\_id](#input\_tenant\_id)

Description: (Optional) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Defaults to the current tenant when omitted.

Type: `string`

Default: `null`

### <a name="input_timeouts"></a> [timeouts](#input\_timeouts)

Description: (Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions.

Type:

```hcl
object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
```

Default: `null`

## Resources

The following resources are used by this module:

- [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) (resource)
- [azurerm_key_vault_access_policy.custom_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault_access_policy) (resource)
- [azurerm_private_endpoint.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/private_endpoint) (resource)
- [azurerm_role_assignment.rbac_keyvault_custom](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) (resource)
- [azurerm_client_config.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) (data source)

## Outputs

The following outputs are exported:

### <a name="output_id"></a> [id](#output\_id)

Description: The ID of the Key Vault.

### <a name="output_keyvault"></a> [keyvault](#output\_keyvault)

Description: Azure Key Vault resource.

### <a name="output_private_endpoint"></a> [private\_endpoint](#output\_private\_endpoint)

Description: The private endpoint resource if created.

### <a name="output_private_endpoint_custom_dns_configs"></a> [private\_endpoint\_custom\_dns\_configs](#output\_private\_endpoint\_custom\_dns\_configs)

Description: The private endpoint custom DNS configs if created.

### <a name="output_private_endpoint_id"></a> [private\_endpoint\_id](#output\_private\_endpoint\_id)

Description: The private endpoint ID if created.

### <a name="output_private_endpoint_ip_configuration"></a> [private\_endpoint\_ip\_configuration](#output\_private\_endpoint\_ip\_configuration)

Description: The private endpoint IP configuration blocks if created.

### <a name="output_private_endpoint_network_interface"></a> [private\_endpoint\_network\_interface](#output\_private\_endpoint\_network\_interface)

Description: The private endpoint network interface block if created.

### <a name="output_private_endpoint_network_interface_id"></a> [private\_endpoint\_network\_interface\_id](#output\_private\_endpoint\_network\_interface\_id)

Description: The private endpoint network interface ID if created.

### <a name="output_private_endpoint_network_interface_name"></a> [private\_endpoint\_network\_interface\_name](#output\_private\_endpoint\_network\_interface\_name)

Description: The private endpoint network interface name if created.

### <a name="output_private_endpoint_private_dns_zone_configs"></a> [private\_endpoint\_private\_dns\_zone\_configs](#output\_private\_endpoint\_private\_dns\_zone\_configs)

Description: The private endpoint private DNS zone configs if created.

### <a name="output_private_endpoint_private_service_connection_private_ip_address"></a> [private\_endpoint\_private\_service\_connection\_private\_ip\_address](#output\_private\_endpoint\_private\_service\_connection\_private\_ip\_address)

Description: The private endpoint private service connection private IP address if created.

### <a name="output_uri"></a> [uri](#output\_uri)

Description: The URI of the Key Vault, used for performing operations on keys and secrets.

<!-- markdownlint-enable -->
<!-- END_TF_DOCS -->