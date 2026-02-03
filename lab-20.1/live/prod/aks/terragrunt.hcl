include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  cluster_name          = "aks-prod"
  resource_group_name   = "rg-aks-prod"
  location              = "eastus"

  system_node_vm_size   = "Standard_DS3_v2"
  system_node_count     = 3
}