provider "azurerm" {
  features {}
}

run "apply_keyvault_basic" {
  command = plan

  module {
    source = "./tests/fixtures/basic"
  }

  variables {
    key_vault_name      = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"
  }

  assert {
    condition     = output.id != null && output.id != ""
    error_message = "Key Vault ID must be exported."
  }

  assert {
    condition     = output.uri != null && output.uri != ""
    error_message = "Key Vault URI must be exported."
  }

  assert {
    condition     = output.private_endpoint == null
    error_message = "Private endpoint must not be created when private_endpoint is not provided."
  }
}

run "plan_custom_access_policy_logic" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"

    access_configurations = [
      {
        object_id               = "00000000-0000-0000-0000-000000000001"
        key_permissions         = ["Get", "List"]
        secret_permissions      = ["Get", "List"]
        certificate_permissions = ["Get", "List"]
      }
    ]
  }

  assert {
    condition     = length(azurerm_key_vault_access_policy.custom_policy) == 1
    error_message = "A custom access policy should be created when RBAC is disabled and access_configurations is provided."
  }

  assert {
    condition     = length(azurerm_role_assignment.rbac_keyvault_custom) == 0
    error_message = "RBAC role assignments should not be created when rbac_authorization_enabled is false."
  }
}

run "plan_inline_access_policy_disables_custom_policy" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"

    access_policies = [
      {
        tenant_id               = "00000000-0000-0000-0000-000000000000"
        object_id               = "00000000-0000-0000-0000-000000000001"
        key_permissions         = ["Get", "List"]
        secret_permissions      = ["Get", "List"]
        certificate_permissions = ["Get", "List"]
      }
    ]

    access_configurations = [
      {
        object_id               = "00000000-0000-0000-0000-000000000001"
        key_permissions         = ["Get", "List"]
        secret_permissions      = ["Get", "List"]
        certificate_permissions = ["Get", "List"]
      }
    ]
  }

  assert {
    condition     = length(azurerm_key_vault_access_policy.custom_policy) == 0
    error_message = "Custom access policy resources must be disabled when inline access_policies are used."
  }
}

run "plan_rbac_logic" {
  command = plan

  variables {
    name                = "kv${substr(replace(uuid(), "-", ""), 0, 20)}"
    location            = "eastus"
    resource_group_name = "rg-${substr(replace(uuid(), "-", ""), 0, 10)}"

    rbac_authorization_enabled = true
    rbac_role_assignments = [
      {
        principal_id         = "00000000-0000-0000-0000-000000000001"
        role_definition_name = "Key Vault Reader"
      }
    ]

    access_configurations = [
      {
        object_id               = "00000000-0000-0000-0000-000000000001"
        key_permissions         = ["Get", "List"]
        secret_permissions      = ["Get", "List"]
        certificate_permissions = ["Get", "List"]
      }
    ]
  }

  assert {
    condition     = length(azurerm_role_assignment.rbac_keyvault_custom) == 1
    error_message = "A custom RBAC role assignment should be created when rbac_authorization_enabled is true."
  }

  assert {
    condition     = length(azurerm_key_vault_access_policy.custom_policy) == 0
    error_message = "Custom access policy resources must be disabled when rbac_authorization_enabled is true."
  }
}