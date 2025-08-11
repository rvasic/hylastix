resource "azurerm_resource_group" "tfstate" {
  name     = var.backend_resource_group
  location = var.location
}

resource "azurerm_storage_account" "tfstate" {
  name                            = var.backend_storage_account
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = var.backend_container
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# OPTIONAL: give your GitHub Actions SP data-plane rights
data "azuread_service_principal" "gha" {
  count          = var.sp_client_id == "" ? 0 : 1
  application_id = var.sp_client_id
}

resource "azurerm_role_assignment" "gha_blob_contrib" {
  count                = var.sp_client_id == "" ? 0 : 1
  scope                = azurerm_storage_account.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_service_principal.gha[0].id
}
