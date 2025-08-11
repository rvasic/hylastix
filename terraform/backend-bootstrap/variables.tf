variable "location" {
  description = "Azure region for the state RG & storage"
  type        = string
  default     = "westeurope"
}

variable "backend_resource_group" {
  description = "Name of the resource group to hold the TF state storage"
  type        = string
}

variable "backend_storage_account" {
  description = "Globally-unique storage account name (lowercase, <=24 chars)"
  type        = string
}

variable "backend_container" {
  description = "Blob container name for the state file"
  type        = string
  default     = "tfstate"
}

variable "backend_key" {
  description = "Blob key (file name) for the state"
  type        = string
  default     = "hylastix.tfstate"
}
