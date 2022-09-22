variable "prefix" {
  type        = string
  description = "Naming prefix for resources"
}

variable "prefixst" {
  type        = string
  description = "Naming prefix for Storage Account"
}

variable "az_rg" {
    type = string
    description = "Resource Group Name"
}

variable "az_location" {
    type    = string
}

variable "az_storage_acc" {
    type = string
}

variable "az_app_registration" {
    type = string
}

variable "az_key_vault_name" {
    type = string
    description = "Key Vault Name"
}

variable "az_container_name" {
  type        = string
  description = "Name of container on storage account for Terraform state"
}

variable "az_key_state" {
  type        = string
  description = "Name of key in storage account for Terraform state"
}

variable "az_client_id" {
    type        = string
    description = "Client ID with permissions to create resources in Azure, use env variables"
}

variable "az_client_secret" {
    type        = string
    description = "Client secret with permissions to create resources in Azure, use env variables"
}

variable "az_subscription" {
    type        = string
    description = "Client ID subscription, use env variables"
}

variable "az_tenant" {
    type        = string
    description = "Client ID Azure AD tenant, use env variables"
}

resource "random_integer" "suffix" {
  min = 1000
  max = 9999
}


