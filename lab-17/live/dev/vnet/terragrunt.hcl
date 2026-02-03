include {
  path = find_in_parent_folders()
}

terraform {
  source = "../../../modules/vnet"
}

inputs = {
  resource_group_name = "rg-dev-network"
  location            = "East US"
}