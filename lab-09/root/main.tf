resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
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

module "aks" {
  source = "../modules/aks"

  rg_name   = azurerm_resource_group.this.name
  location  = var.location
  subnet_id = module.network.subnet_ids["aks"]

  environment = var.environment
  common_tags = var.common_tags
}