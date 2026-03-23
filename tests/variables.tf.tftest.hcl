provider "azurerm" {
  features {}
}

run "valid_minimal_input" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
  }
}

run "invalid_sku_name" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    sku_name            = "invalid"
  }

  expect_failures = [
    var.sku_name,
  ]
}

run "invalid_soft_delete_retention_days_low" {
  command = plan

  variables {
    name                       = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location                   = "eastus"
    resource_group_name        = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    soft_delete_retention_days = 6
  }

  expect_failures = [
    var.soft_delete_retention_days,
  ]
}

run "invalid_soft_delete_retention_days_high" {
  command = plan

  variables {
    name                       = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location                   = "eastus"
    resource_group_name        = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    soft_delete_retention_days = 91
  }

  expect_failures = [
    var.soft_delete_retention_days,
  ]
}

run "invalid_network_acls_bypass" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    network_acls = {
      bypass         = "Invalid"
      default_action = "Deny"
    }
  }

  expect_failures = [
    var.network_acls,
  ]
}

run "invalid_network_acls_default_action" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    network_acls = {
      bypass         = "AzureServices"
      default_action = "Invalid"
    }
  }

  expect_failures = [
    var.network_acls,
  ]
}

run "invalid_access_configurations_object_id" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    access_configurations = [
      {
        object_id = "not-a-guid"
      }
    ]
  }

  expect_failures = [
    var.access_configurations,
  ]
}

run "invalid_rbac_role_assignments_principal_id" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    rbac_role_assignments = [
      {
        principal_id         = "not-a-guid"
        role_definition_name = "Key Vault Reader"
      }
    ]
  }

  expect_failures = [
    var.rbac_role_assignments,
  ]
}

run "invalid_private_endpoint_missing_connection_target" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    private_endpoint = {
      name                = "pe-${substr(replace(uuid(), "-", ""), 0, 8)}"
      location            = "eastus"
      resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 8)}"
      subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-${substr(replace(uuid(), "-", ""), 0, 8)}/providers/Microsoft.Network/virtualNetworks/vnet-${substr(replace(uuid(), "-", ""), 0, 8)}/subnets/snet-${substr(replace(uuid(), "-", ""), 0, 8)}"
      private_service_connection = {
        name                 = "psc-${substr(replace(uuid(), "-", ""), 0, 8)}"
        is_manual_connection = false
      }
    }
  }

  expect_failures = [
    var.private_endpoint,
  ]
}

run "invalid_private_endpoint_request_message_without_manual" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    private_endpoint = {
      name                = "pe-${substr(replace(uuid(), "-", ""), 0, 8)}"
      location            = "eastus"
      resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 8)}"
      subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-${substr(replace(uuid(), "-", ""), 0, 8)}/providers/Microsoft.Network/virtualNetworks/vnet-${substr(replace(uuid(), "-", ""), 0, 8)}/subnets/snet-${substr(replace(uuid(), "-", ""), 0, 8)}"
      private_service_connection = {
        name                           = "psc-${substr(replace(uuid(), "-", ""), 0, 8)}"
        is_manual_connection           = false
        private_connection_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-${substr(replace(uuid(), "-", ""), 0, 8)}/providers/Microsoft.KeyVault/vaults/kv${substr(replace(uuid(), "-", ""), 0, 10)}"
        request_message                = "hello"
      }
    }
  }

  expect_failures = [
    var.private_endpoint,
  ]
}

run "invalid_private_endpoint_request_message_too_long" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
    private_endpoint = {
      name                = "pe-${substr(replace(uuid(), "-", ""), 0, 8)}"
      location            = "eastus"
      resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 8)}"
      subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-${substr(replace(uuid(), "-", ""), 0, 8)}/providers/Microsoft.Network/virtualNetworks/vnet-${substr(replace(uuid(), "-", ""), 0, 8)}/subnets/snet-${substr(replace(uuid(), "-", ""), 0, 8)}"
      private_service_connection = {
        name                           = "psc-${substr(replace(uuid(), "-", ""), 0, 8)}"
        is_manual_connection           = true
        private_connection_resource_id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-${substr(replace(uuid(), "-", ""), 0, 8)}/providers/Microsoft.KeyVault/vaults/kv${substr(replace(uuid(), "-", ""), 0, 10)}"
        request_message                = "${uuid()}${uuid()}${uuid()}${uuid()}"
      }
    }
  }

  expect_failures = [
    var.private_endpoint,
  ]
}