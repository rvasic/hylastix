variable "resource_group_name" {
  default = "hylastix-rg"
}
variable "location" {
  default = "westeurope"
}
variable "vm_admin_username" {
  default = "azureuser"
}
variable "ssh_public_key_data" {
  type      = string
  sensitive = true
}