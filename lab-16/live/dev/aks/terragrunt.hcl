include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/aks"
}

inputs = {
  resource_group_name = "rg-dev-aks"
  location            = "East US"
  cluster_name        = "aks-dev"
}