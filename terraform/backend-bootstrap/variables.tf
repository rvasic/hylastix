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

# Optional: grant the GitHub Actions SP data-plane access
# Pass your SP application (client) ID; leave empty to skip.
variable "sp_client_id" {
  description = "Application (client) ID of the GitHub Actions service principal for role assignment"
  type        = string
  default     = ""
}
