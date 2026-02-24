variable "resource_group_name" {
  description = "Name of the Azure Resource Group."
  type        = string
  default     = "lighthouse"
}

variable "location" {
  description = "Azure region for the Resource Group (e.g., East US, westeurope)."
  type        = string
  default     = "East US"
}

variable "subscription_id" {
  description = "Azure Subscription ID to target. If null, Terraform uses the current Azure CLI/account context."
  type        = string
  default     = null
}

variable "tenant_id" {
  description = "Azure Tenant ID. Usually optional; set if you need to force a tenant."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the Resource Group."
  type        = map(string)
  default = {
    environment = "lighthouse"
  }

  validation {
    condition = (
      contains(keys(var.tags), "SbxResourceGroupOwner")
      && can(regex(".*@zeiss\\.com$", lower(var.tags["SbxResourceGroupOwner"])))
    )
    error_message = "tags must include SbxResourceGroupOwner with a value ending in @zeiss.com (example: firstname.lastname@zeiss.com)."
  }
}
