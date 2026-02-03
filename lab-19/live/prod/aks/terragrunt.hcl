include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

dependency "network" {
  config_path = "../../network"
}

inputs = {
  cluster_name        = "aks-prod-private"
  resource_group_name = "rg-aks-prod"
  location            = "eastus"

  system_node_vm_size = "Standard_DS3_v2"
  system_node_count   = 3

  subnet_id = dependency.network.outputs.aks_subnet_id

  api_server_authorized_ips = [
    "203.0.113.10/32"   # VPN / jumpbox IP
  ]
}