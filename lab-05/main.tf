locals {
  rg_name = "${var.resource_group_name}-${var.environment}"
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}