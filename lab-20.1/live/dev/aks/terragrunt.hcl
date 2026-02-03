include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  cluster_name          = "aks-dev"
  resource_group_name   = "rg-aks-dev"
  location              = "eastus"

  system_node_vm_size   = "Standard_DS2_v2"
  system_node_count     = 1
}
