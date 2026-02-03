resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name           = "system"
    vm_size        = "Standard_DS2_v2"
    node_count     = 2
    vnet_subnet_id = var.subnet_id  # <--- uses subnet input
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}