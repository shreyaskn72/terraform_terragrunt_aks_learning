resource "azurerm_kubernetes_cluster" "this" {
  name                = "aks-${var.environment}"
  location            = var.location
  resource_group_name = var.rg_name
  dns_prefix          = "aks-${var.environment}"

  default_node_pool {
    name           = "system"
    node_count     = 2
    vm_size        = "Standard_DS2_v2"
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "azure"
  }

  tags = merge(
    var.common_tags,
    {
      environment = var.environment
    }
  )
}