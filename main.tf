

# Create a Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-${var.az_rg}"
  location = var.az_location
}

# Create a storage account
resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefixst}${var.az_storage_acc}${random_integer.suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.az_location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Create a container for terraform state
resource "azurerm_storage_container" "sc" {
  name                  = "${var.prefixst}-${var.az_container_name}"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

# Create a random password
resource "random_password" "sp_secret" {
  length           = 32
  special          = true
  min_numeric      = 5
  min_special      = 4
  override_special = "-_%@?"
}

# Create an "App Registrations" in Azure AD with random password
resource "azuread_application" "app_registration" {
  display_name = "${var.prefix}-${var.az_app_registration}"

  depends_on = [
    azurerm_resource_group.rg
  ]
}

# resource "azuread_application_password" "sp_secret" {
#   application_object_id = azuread_application.app_registration.object_id
#   value                 = random_password.sp_secret.result
#   end_date_relative     = "168h" # 7 days
# }

# Reference AAD App Registration as Service Principal for next step
resource "azuread_service_principal" "sp" {
  application_id = azuread_application.app_registration.application_id
}

# Set the scope Service Principal to Resource Group
resource "azurerm_role_assignment" "sp" {
  role_definition_name = "Contributor"
  principal_id         = azuread_service_principal.sp.id
  scope                = azurerm_resource_group.rg.id
}


# Key Vault
# ---------

# get reference to local Azure client and subscription
data "azurerm_client_config" "current" {}

data "azurerm_subscription" "current" {}

# output "account_id" {
#   value = "${data.azurerm_client_config.current.service_principal_application_id}"
# }

# Create Key Vault
resource "azurerm_key_vault" "kv" {
  name                        = "${var.prefix}-${var.az_key_vault_name}${random_integer.suffix.result}"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7     # minimum
  purge_protection_enabled    = false # so we can fully delete it
  sku_name                    = "standard"
}

# Give local client access to key vault
resource "azurerm_key_vault_access_policy" "self" {
  key_vault_id = azurerm_key_vault.kv.id
  object_id    = data.azurerm_client_config.current.object_id
  tenant_id    = data.azurerm_client_config.current.tenant_id

  secret_permissions = [
    "Backup",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Recover",
    "Restore",
    "Set"
  ]
}

# Store Service Principal client ID and secret in Key Vault
# Note: we need to wait for access policy before we can add secrets

resource "azurerm_key_vault_secret" "sp_client_id" {
  name         = var.az_client_id
  value        = azuread_application.app_registration.application_id
  key_vault_id = azurerm_key_vault.kv.id

  depends_on   = [
    azurerm_key_vault_access_policy.self
  ]
}

resource "azurerm_key_vault_secret" "sp_client_secret" {
  name         = var.az_client_secret
  value        = random_password.sp_secret.result
  key_vault_id = azurerm_key_vault.kv.id

  depends_on   = [
    azurerm_key_vault_access_policy.self
  ]
}