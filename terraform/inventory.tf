resource "local_file" "ansible_inventory" {
  content = <<EOT
[web]
${azurerm_linux_virtual_machine.vm.public_ip_address} ansible_user=azureuser ansible_ssh_private_key_file=/mnt/c/Users/noitr/.ssh/id_rsa
EOT
  filename = "${path.module}/../ansible/inventory.ini"
}