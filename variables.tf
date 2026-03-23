variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "name" {
  description = "(Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created. The name must be globally unique. If the vault is in a recoverable state then the vault will need to be purged before reusing the name."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created."
  type        = string
}

variable "access_configurations" {
  description = <<EOF
  (Optional) A list of Key Vault Access Policy configurations managed through separate `azurerm_key_vault_access_policy` resources.
    tenant_id : (Optional) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault.
    object_id : (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.
    application_id : (Optional) The object ID of an Application in Azure Active Directory.
    certificate_permissions : (Optional) List of certificate permissions.
    key_permissions : (Optional) List of key permissions.
    secret_permissions : (Optional) List of secret permissions.
    storage_permissions : (Optional) List of storage permissions.
  EOF
  type = list(object({
    tenant_id               = optional(string)
    object_id               = string
    application_id          = optional(string)
    certificate_permissions = optional(list(string))
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
  default = []

  validation {
    condition = alltrue([
      for policy in var.access_configurations : can(regex("^[0-9a-fA-F-]{36}$", policy.object_id))
    ])
    error_message = "`access_configurations[*].object_id` must be a valid GUID."
  }
}

variable "access_policies" {
  description = <<EOF
  (Optional) A list of access_policy objects (up to 1024) describing access policies, as described below.
    tenant_id : (Optional) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault.
    object_id : (Required) The object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.
    application_id : (Optional) The object ID of an Application in Azure Active Directory.
    certificate_permissions : (Optional) List of certificate permissions.
    key_permissions : (Optional) List of key permissions.
    secret_permissions : (Optional) List of secret permissions.
    storage_permissions : (Optional) List of storage permissions.
  EOF
  type = list(object({
    tenant_id               = string
    object_id               = string
    application_id          = optional(string)
    certificate_permissions = optional(list(string))
    key_permissions         = optional(list(string))
    secret_permissions      = optional(list(string))
    storage_permissions     = optional(list(string))
  }))
  default = []
}

variable "enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = <<DESCRIPTION
	(Optional) A network_acls block as defined below.
		bypass : (Required) Specifies which traffic can bypass the network rules. Possible values are `AzureServices` and `None`.
		default_action : (Required) The Default Action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`. Possible values are `Allow` and `Deny`.
		ip_rules : (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.
		virtual_network_subnet_ids : (Optional) One or more Subnet IDs which should be able to access this Key Vault.
	DESCRIPTION
  type = object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = optional(list(string)),
    virtual_network_subnet_ids = optional(list(string)),
  })
  default = null

  validation {
    condition     = var.network_acls == null ? true : contains(["AzureServices", "None"], var.network_acls.bypass)
    error_message = "`network_acls.bypass` must be one of: \"AzureServices\", \"None\"."
  }
  validation {
    condition     = var.network_acls == null ? true : contains(["Allow", "Deny"], var.network_acls.default_action)
    error_message = "`network_acls.default_action` must be one of: \"Allow\", \"Deny\"."
  }

}

variable "private_endpoint" {
  description = <<EOF
  (Optional) Private endpoint configuration. If provided, a private endpoint is created.
    name : (Required) Specifies the Name of the Private Endpoint. Changing this forces a new resource to be created.
    resource_group_name : (Required) Specifies the Name of the Resource Group within which the Private Endpoint should exist. Changing this forces a new resource to be created.
    location : (Required) The supported Azure location where the resource exists. Changing this forces a new resource to be created.
    subnet_id : (Required) The ID of the Subnet from which Private IP Addresses will be allocated for this Private Endpoint. Changing this forces a new resource to be created.
    custom_network_interface_name : (Optional) The custom name of the network interface attached to the private endpoint. Changing this forces a new resource to be created.
    tags : (Optional) A mapping of tags to assign to the resource.
    private_service_connection : (Required) A `private_service_connection` block as defined below.
      name : (Required) Specifies the Name of the Private Service Connection. Changing this forces a new resource to be created.
      is_manual_connection : (Required) Does the Private Endpoint require Manual Approval from the remote resource owner? Changing this forces a new resource to be created.
      private_connection_resource_id : (Optional) The ID of the Private Link Enabled Remote Resource to connect to. One of this or `private_connection_resource_alias` must be specified.
      private_connection_resource_alias : (Optional) The Service Alias of the Private Link Enabled Remote Resource to connect to. One of this or `private_connection_resource_id` must be specified.
      subresource_names : (Optional) A list of subresource names which the Private Endpoint is able to connect to.
      request_message : (Optional) A message passed to the owner of the remote resource when the private endpoint attempts to establish the connection. Only valid if `is_manual_connection` is `true`.
    private_dns_zone_group : (Optional) One or more `private_dns_zone_group` blocks as defined below.
      name : (Required) Specifies the Name of the Private DNS Zone Group.
      private_dns_zone_ids : (Required) Specifies the list of Private DNS Zones to include within the `private_dns_zone_group`.
    ip_configuration : (Optional) One or more `ip_configuration` blocks as defined below.
      name : (Required) Specifies the Name of the IP Configuration. Changing this forces a new resource to be created.
      private_ip_address : (Required) Specifies the static IP address within the private endpoint's subnet to be used. Changing this forces a new resource to be created.
      subresource_name : (Optional) Specifies the subresource this IP address applies to.
      member_name : (Optional) Specifies the member name this IP address applies to. If it is not specified, it will use the value of `subresource_name`.
  EOF
  type = object({
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
  default = null

  validation {
    condition = var.private_endpoint == null ? true : (
      length(trimspace(var.private_endpoint.subnet_id)) > 0 &&
      length(trimspace(var.private_endpoint.name)) > 0 &&
      length(trimspace(var.private_endpoint.resource_group_name)) > 0 &&
      length(trimspace(var.private_endpoint.location)) > 0 &&
      length(trimspace(var.private_endpoint.private_service_connection.name)) > 0 &&
      (
        var.private_endpoint.private_service_connection.private_connection_resource_id != null ||
        var.private_endpoint.private_service_connection.private_connection_resource_alias != null
      ) &&
      (
        var.private_endpoint.private_service_connection.request_message == null ||
        var.private_endpoint.private_service_connection.is_manual_connection == true
      ) &&
      (
        var.private_endpoint.private_service_connection.request_message == null ||
        length(var.private_endpoint.private_service_connection.request_message) <= 140
      )
    )
    error_message = "private_endpoint must include name, location, resource_group_name, subnet_id, and private_service_connection details with a resource id or alias. request_message requires is_manual_connection = true and must be 140 characters or fewer."
  }
}

variable "purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault. "
  type        = bool
  default     = true
}

variable "rbac_authorization_enabled" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = false
}

variable "rbac_role_assignments" {
  description = <<DESCRIPTION
  (Optional) RBAC role assignments to configure on the Key Vault when RBAC authorization is enabled.
    principal_id         = (Required) The principal ID to assign the role to.
    role_definition_name = (Required) The built-in role name to assign (for example, `Key Vault Administrator`).
  DESCRIPTION
  type = list(object({
    principal_id         = string
    role_definition_name = string
  }))
  default = []

  validation {
    condition = alltrue([
      for assignment in var.rbac_role_assignments : can(regex("^[0-9a-fA-F-]{36}$", assignment.principal_id))
    ])
    error_message = "`rbac_role_assignments[*].principal_id` must be a valid GUID."
  }
}

variable "sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`."
  type        = string
  default     = "standard"


  validation {
    condition     = var.sku_name == null ? true : contains(["standard", "premium"], var.sku_name)
    error_message = "`sku_name` must be one of: \"standard\", \"premium\"."
  }
}

variable "soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between `7` and `90` days."
  type        = number
  default     = 7


  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "`soft_delete_retention_days` must be between 7 and 90."
  }
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

variable "tenant_id" {
  description = "(Optional) The Azure Active Directory tenant ID that should be used for authenticating requests to the key vault. Defaults to the current tenant when omitted."
  type        = string
  default     = null
}

variable "timeouts" {
  description = "(Optional) A `timeouts` block to configure operation timeouts for create, read, update, and delete actions."
  type = object({
    create = optional(string)
    read   = optional(string)
    update = optional(string)
    delete = optional(string)
  })
  default = null
}
