variable "resource_group_name" {
  default = "hylastix-rg"
}
variable "location" {
  default = "West Europe"
}
variable "vm_admin_username" {
  default = "azureuser"
}
variable "ssh_public_key" {
  default = "/mnt/c/Users/noitr/.ssh/id_rsa.pub"
}