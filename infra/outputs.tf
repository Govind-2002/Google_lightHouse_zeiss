output "resource_group_id" {
  description = "Resource Group ID."
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Resource Group name."
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "Resource Group location/region."
  value       = azurerm_resource_group.rg.location
}
