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
  description = "Path to SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}
