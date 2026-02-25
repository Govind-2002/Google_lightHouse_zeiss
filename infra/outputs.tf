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

output "vm_public_ip" {
  description = "Public IP address of the VM."
  value       = azurerm_public_ip.public_ip.ip_address
}

output "vm_private_ip" {
  description = "Private IP address of the VM."
  value       = azurerm_network_interface.nic.private_ip_address
}
