resource "azurerm_resource_group" "this" {
  name     = var.resource_group_name
  location = var.location
}


#AKS Cluster (System Node Pool Only)
resource "azurerm_kubernetes_cluster" "this" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = var.cluster_name

  kubernetes_version = var.kubernetes_version

  default_node_pool {
    name       = "system"
    vm_size    = "Standard_DS2_v2"
    node_count = 2
  }

  identity {
    type = "SystemAssigned"
  }
}


#User Node Pool (Autoscaling)
resource "azurerm_kubernetes_cluster_node_pool" "user" {
  name                  = "userpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_DS2_v2"

  mode = "User"

  enable_auto_scaling = true
  min_count           = 1
  max_count           = 5

  node_labels = {
    workload = "general"
  }
}


#Spot Node Pool (Cheap Compute)
resource "azurerm_kubernetes_cluster_node_pool" "spot" {
  name                  = "spotpool"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = "Standard_DS2_v2"

  mode = "User"

  priority        = "Spot"
  eviction_policy = "Delete"
  spot_max_price  = -1

  enable_auto_scaling = true
  min_count           = 0
  max_count           = 3

  node_labels = {
    workload = "spot"
  }

  node_taints = [
    "kubernetes.azure.com/scalesetpriority=spot:NoSchedule"
  ]
}