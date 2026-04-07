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

variable "admin_password" {
  description = "Admin password for the virtual machine. Must meet Azure's complexity requirements."
  type        = string
  sensitive   = true
}

# ── AKS variables ──────────────────────────────────────────────────────────────

variable "aks_cluster_name" {
  description = "Name of the AKS cluster."
  type        = string
  default     = "aks-sre-peacemaker-dev"
}

variable "aks_dns_prefix" {
  description = "DNS prefix for the AKS cluster."
  type        = string
  default     = "lighthouse-aks"
}

variable "aks_node_count" {
  description = "Number of nodes in the default node pool."
  type        = number
  default     = 2
}

variable "aks_node_vm_size" {
  description = "VM size for AKS node pool."
  type        = string
  default     = "Standard_B4ms"
}
