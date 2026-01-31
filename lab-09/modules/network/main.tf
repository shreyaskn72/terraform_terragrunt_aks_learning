locals {
  enable_ddos = var.environment == "prod" ? true : false
}

resource "azurerm_virtual_network" "this" {
  name                = "vnet-${var.environment}"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = var.rg_name

  tags = merge(
    var.common_tags,
    {
      environment = var.environment
    }
  )
}

resource "azurerm_network_security_group" "this" {
  name                = "nsg-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name

  dynamic "security_rule" {
    for_each = var.nsg_rules

    content {
      name                       = security_rule.key
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                      = security_rule.value.access
      protocol                    = security_rule.value.protocol
      source_address_prefix       = security_rule.value.source
      destination_address_prefix  = security_rule.value.destination
      destination_port_range      = security_rule.value.port
    }
  }
}

resource "azurerm_subnet" "this" {
  for_each = var.subnets

  name                 = each.key
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes     = [each.value.address_prefix]
}
