output "public_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
output "admin_username" {
  value = var.vm_admin_username
}
output "vm_ip" {
  value = azurerm_linux_virtual_machine.vm.public_ip_address
}
