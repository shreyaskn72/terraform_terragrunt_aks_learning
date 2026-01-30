output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.rg.name
}

output "resource_group_location" {
  description = "The Azure region of the resource group"
  value       = azurerm_resource_group.rg.location
}