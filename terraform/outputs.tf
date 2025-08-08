output "public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
output "admin_username" {
  value = var.vm_admin_username
}
