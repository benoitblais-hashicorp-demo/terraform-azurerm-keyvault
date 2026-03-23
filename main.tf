data "azurerm_client_config" "this" {}

resource "azurerm_key_vault" "this" {
  name                            = lower(var.name)
  location                        = var.location
  resource_group_name             = var.resource_group_name
  tenant_id                       = coalesce(var.tenant_id, data.azurerm_client_config.this.tenant_id)
  sku_name                        = var.sku_name
  enabled_for_deployment          = var.enabled_for_deployment
  enabled_for_disk_encryption     = var.enabled_for_disk_encryption
  enabled_for_template_deployment = var.enabled_for_template_deployment
  soft_delete_retention_days      = var.soft_delete_retention_days
  purge_protection_enabled        = var.purge_protection_enabled
  rbac_authorization_enabled      = var.rbac_authorization_enabled
  public_network_access_enabled   = var.public_network_access_enabled
  tags                            = var.tags

  dynamic "access_policy" {
    for_each = var.access_policies
    content {
      tenant_id               = access_policy.value.tenant_id
      object_id               = access_policy.value.object_id
      application_id          = access_policy.value.application_id
      certificate_permissions = access_policy.value.certificate_permissions
      key_permissions         = access_policy.value.key_permissions
      secret_permissions      = access_policy.value.secret_permissions
      storage_permissions     = access_policy.value.storage_permissions
    }
  }

  dynamic "network_acls" {
    for_each = var.network_acls != null ? [true] : []
    content {
      bypass                     = var.network_acls.bypass
      default_action             = var.network_acls.default_action
      ip_rules                   = var.network_acls.ip_rules
      virtual_network_subnet_ids = var.network_acls.virtual_network_subnet_ids
    }
  }

  dynamic "timeouts" {
    for_each = var.timeouts != null ? [var.timeouts] : []
    content {
      create = timeouts.value.create
      read   = timeouts.value.read
      update = timeouts.value.update
      delete = timeouts.value.delete
    }
  }

}

resource "azurerm_key_vault_access_policy" "custom_policy" {
  for_each = var.rbac_authorization_enabled || length(var.access_policies) > 0 ? {} : {
    for index, policy in var.access_configurations : tostring(index) => policy
  }

  key_vault_id = azurerm_key_vault.this.id
  tenant_id    = coalesce(try(each.value.tenant_id, null), coalesce(var.tenant_id, data.azurerm_client_config.this.tenant_id))
  object_id    = each.value.object_id

  application_id          = try(each.value.application_id, null)
  certificate_permissions = try(each.value.certificate_permissions, null)
  key_permissions         = try(each.value.key_permissions, null)
  secret_permissions      = try(each.value.secret_permissions, null)
  storage_permissions     = try(each.value.storage_permissions, null)
}

resource "azurerm_role_assignment" "rbac_keyvault_custom" {
  for_each = var.rbac_authorization_enabled ? {
    for index, assignment in var.rbac_role_assignments : tostring(index) => assignment
  } : {}

  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value.role_definition_name
  principal_id         = each.value.principal_id
}

resource "azurerm_private_endpoint" "this" {
  for_each = var.private_endpoint == null ? {} : { "default" = var.private_endpoint }

  name                          = each.value.name
  location                      = each.value.location
  resource_group_name           = each.value.resource_group_name
  subnet_id                     = each.value.subnet_id
  custom_network_interface_name = try(each.value.custom_network_interface_name, null)
  tags                          = try(each.value.tags, null)

  private_service_connection {
    name                              = each.value.private_service_connection.name
    is_manual_connection              = each.value.private_service_connection.is_manual_connection
    private_connection_resource_id    = each.value.private_service_connection.private_connection_resource_alias == null ? coalesce(try(each.value.private_service_connection.private_connection_resource_id, null), azurerm_key_vault.this.id) : null
    private_connection_resource_alias = try(each.value.private_service_connection.private_connection_resource_alias, null)
    subresource_names                 = coalesce(try(each.value.private_service_connection.subresource_names, null), ["vault"])
    request_message                   = try(each.value.private_service_connection.request_message, null)
  }

  dynamic "private_dns_zone_group" {
    for_each = try(each.value.private_dns_zone_group, [])

    content {
      name                 = private_dns_zone_group.value.name
      private_dns_zone_ids = private_dns_zone_group.value.private_dns_zone_ids
    }
  }

  dynamic "ip_configuration" {
    for_each = try(each.value.ip_configuration, [])

    content {
      name               = ip_configuration.value.name
      private_ip_address = ip_configuration.value.private_ip_address
      subresource_name   = try(ip_configuration.value.subresource_name, null)
      member_name        = try(ip_configuration.value.member_name, null)
    }
  }
}
