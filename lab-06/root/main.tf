locals {
  rg_name = "${var.resource_group_name}-${var.environment}"
}

module "resource_group" {
  source   = "../modules/resource-group"
  name     = local.rg_name
  location = var.location
}