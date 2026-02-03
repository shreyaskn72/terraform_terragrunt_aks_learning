network_profile {
  network_plugin = "azure"
}

default_node_pool {
  name           = "system"
  vm_size        = "Standard_DS2_v2"
  node_count     = 2
  vnet_subnet_id = var.subnet_id
}