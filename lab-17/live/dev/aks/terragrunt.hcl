include {
  path = find_in_parent_folders()
}

dependency "vnet" {
  config_path = "../vnet"
}


terraform {
  source = "../../../modules/aks"
}

inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"

  subnet_id = dependency.vnet.outputs.subnet_id
}