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
