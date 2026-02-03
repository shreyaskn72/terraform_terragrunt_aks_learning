resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.cluster_name

  # 🔒 PRIVATE CLUSTER
  private_cluster_enabled = true

  default_node_pool {
    name           = "system"
    vm_size        = var.system_node_vm_size
    node_count     = var.system_node_count
    vnet_subnet_id = var.subnet_id
  }

  identity {
    type = "SystemAssigned"
  }

  # 🔐 NETWORK HARDENING
  network_profile {
    network_plugin    = "azure"
    network_policy    = "azure"   # Enables Network Policies
    load_balancer_sku = "standard"
  }

  # 🔐 API SERVER ACCESS RESTRICTION
  api_server_access_profile {
    authorized_ip_ranges = var.api_server_authorized_ips
  }
}