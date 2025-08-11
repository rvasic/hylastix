output "backend_resource_group" {
  value = azurerm_resource_group.tfstate.name
}

output "backend_storage_account" {
  value = azurerm_storage_account.tfstate.name
}

output "backend_container" {
  value = azurerm_storage_container.tfstate.name
}

output "backend_key" {
  value = var.backend_key
}

# NEW: use this to init the azurerm backend without RBAC
output "storage_account_access_key" {
  value     = azurerm_storage_account.tfstate.primary_access_key
  sensitive = true
}
