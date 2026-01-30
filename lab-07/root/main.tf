resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location

  tags = var.common_tags
}

module "network" {
  source = "../modules/network"

  rg_name     = azurerm_resource_group.this.name
  location    = var.location
  environment = var.environment

  subnets   = var.subnets
  nsg_rules = var.nsg_rules

  common_tags = var.common_tags
}
